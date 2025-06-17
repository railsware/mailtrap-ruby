# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module Mailtrap
  class Client
    SENDING_API_HOST = 'send.api.mailtrap.io'
    BULK_SENDING_API_HOST = 'bulk.api.mailtrap.io'
    SANDBOX_API_HOST = 'sandbox.api.mailtrap.io'
    API_PORT = 443
    API_HOST = 'mailtrap.io'

    attr_reader :api_key, :api_host, :api_port, :bulk, :sandbox, :inbox_id

    # Initializes a new Mailtrap::Client instance.
    #
    # @param [String] api_key The Mailtrap API key to use for sending. Required.
    #                         If not set, is taken from the MAILTRAP_API_KEY environment variable.
    # @param [String, nil] api_host The Mailtrap API hostname. If not set, is chosen internally.
    # @param [Integer] api_port The Mailtrap API port. Default: 443.
    # @param [Boolean] bulk Whether to use the Mailtrap bulk sending API. Default: false.
    #                       If enabled, is incompatible with `sandbox: true`.
    # @param [Boolean] sandbox Whether to use the Mailtrap sandbox API. Default: false.
    #                          If enabled, is incompatible with `bulk: true`.
    # @param [Integer] inbox_id The sandbox inbox ID to send to. Required if sandbox API is used.
    def initialize( # rubocop:disable Metrics/ParameterLists
      api_key: ENV.fetch('MAILTRAP_API_KEY'),
      api_host: nil,
      api_port: API_PORT,
      bulk: false,
      sandbox: false,
      inbox_id: nil,
      general_api_host: API_HOST
    )
      raise ArgumentError, 'api_key is required' if api_key.nil?
      raise ArgumentError, 'api_port is required' if api_port.nil?
      raise ArgumentError, 'bulk mode is not applicable for sandbox API' if sandbox && bulk

      api_host ||= select_api_host(bulk:, sandbox:)
      raise ArgumentError, 'inbox_id is required for sandbox API' if sandbox && inbox_id.nil?

      @api_key = api_key
      @api_host = api_host
      @api_port = api_port
      @bulk = bulk
      @sandbox = sandbox
      @inbox_id = inbox_id
      @general_api_host = general_api_host
    end

    # Sends a batch of emails
    # @param base [Mailtrap::Mail::Base] The base email configuration
    # @param requests [Array<Mailtrap::Mail::Base>] Array of individual email requests
    # @return [Hash] The JSON response
    def send_batch(base, requests)
      raise ArgumentError, 'base should be Mailtrap::Mail::Base object' unless base.is_a?(Mail::Base)

      unless requests.all?(Mail::Base)
        raise ArgumentError,
              'requests should be an array of Mailtrap::Mail::Base objects'
      end

      uri = URI::HTTP.build(
        host: api_host,
        port: api_port,
        path: batch_request_url
      )

      perform_request(:post, uri, {
                        base: compact_with_empty_arrays(base.as_json),
                        requests:
                      })
    end

    def send(mail)
      raise ArgumentError, 'should be Mailtrap::Mail::Base object' unless mail.is_a? Mail::Base

      uri = URI::HTTP.build(host: api_host, port: api_port, path: request_url)
      perform_request(:post, uri, mail)
    end

    # Performs a GET request to the specified path
    # @param path [String] The request path
    # @return [Hash] The JSON response
    def get(path)
      uri = URI::HTTP.build(host: @general_api_host, port: @api_port, path:)
      perform_request(:get, uri)
    end

    # Performs a POST request to the specified path
    # @param path [String] The request path
    # @param body [Hash] The request body
    # @return [Hash] The JSON response
    def post(path, body = nil)
      uri = URI::HTTP.build(host: @general_api_host, port: @api_port, path:)
      perform_request(:post, uri, body)
    end

    # Performs a PATCH request to the specified path
    # @param path [String] The request path
    # @param body [Hash] The request body
    # @return [Hash] The JSON response
    def patch(path, body = nil)
      uri = URI::HTTP.build(host: @general_api_host, port: @api_port, path:)
      perform_request(:patch, uri, body)
    end

    # Performs a DELETE request to the specified path
    # @param path [String] The request path
    # @return [Hash] The JSON response
    def delete(path)
      uri = URI::HTTP.build(host: @general_api_host, port: @api_port, path:)
      perform_request(:delete, uri)
    end

    private

    def select_api_host(bulk:, sandbox:)
      raise ArgumentError, 'bulk mode is not applicable for sandbox API' if bulk && sandbox

      if sandbox
        SANDBOX_API_HOST
      elsif bulk
        BULK_SENDING_API_HOST
      else
        SENDING_API_HOST
      end
    end

    def request_url
      "/api/send#{sandbox ? "/#{inbox_id}" : ""}"
    end

    def batch_request_url
      "/api/batch#{sandbox ? "/#{inbox_id}" : ""}"
    end

    def perform_request(method, uri, body = nil)
      http_client = Net::HTTP.new(uri.host, @api_port)
      http_client.use_ssl = true
      request = setup_request(method, uri.path, body)
      response = http_client.request(request)
      handle_response(response)
    end

    def setup_request(method, path, body = nil)
      request = case method
                when :get
                  Net::HTTP::Get.new(path)
                when :post
                  Net::HTTP::Post.new(path)
                when :patch
                  Net::HTTP::Patch.new(path)
                when :delete
                  Net::HTTP::Delete.new(path)
                else
                  raise ArgumentError, "Unsupported HTTP method: #{method}"
                end

      request.body = body.to_json if body
      request['Authorization'] = "Bearer #{api_key}"
      request['Content-Type'] = 'application/json'
      request['User-Agent'] = 'mailtrap-ruby (https://github.com/railsware/mailtrap-ruby)'

      request
    end

    def handle_response(response) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      case response
      when Net::HTTPOK, Net::HTTPCreated
        json_response(response.body)
      when Net::HTTPNoContent
        true
      when Net::HTTPBadRequest
        raise Mailtrap::Error, json_response(response.body)[:errors]
      when Net::HTTPUnauthorized
        body = json_response(response.body)
        raise Mailtrap::AuthorizationError, [body[:errors] || body[:error]].flatten
      when Net::HTTPForbidden
        raise Mailtrap::RejectionError, json_response(response.body)[:errors]
      when Net::HTTPPayloadTooLarge
        raise Mailtrap::MailSizeError, ['message too large']
      when Net::HTTPTooManyRequests
        raise Mailtrap::RateLimitError, ['too many requests']
      when Net::HTTPClientError
        raise Mailtrap::Error, ['client error:', response.body]
      when Net::HTTPServerError
        raise Mailtrap::Error, ['server error']
      else
        raise Mailtrap::Error, ["unexpected status code=#{response.code}"]
      end
    end

    def json_response(body)
      JSON.parse(body, symbolize_names: true)
    end

    def compact_with_empty_arrays(hash)
      hash.reject { |_, v| v.nil? || (v.is_a?(Array) && v.empty?) }
    end
  end
end
