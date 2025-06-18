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
    GENERAL_API_HOST = 'mailtrap.io'

    attr_reader :api_key, :api_host, :api_port, :bulk, :sandbox, :inbox_id, :general_api_host

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
    # @param [String] general_api_host The general API hostname for non-sending operations. Default: mailtrap.io.
    def initialize( # rubocop:disable Metrics/ParameterLists
      api_key: ENV.fetch('MAILTRAP_API_KEY'),
      api_host: nil,
      api_port: API_PORT,
      bulk: false,
      sandbox: false,
      inbox_id: nil,
      general_api_host: GENERAL_API_HOST
    )
      raise ArgumentError, 'api_key is required' if api_key.nil?
      raise ArgumentError, 'api_port is required' if api_port.nil?

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

    def send(mail)
      raise ArgumentError, 'should be Mailtrap::Mail::Base object' unless mail.is_a? Mail::Base

      uri = URI::HTTP.build(host: api_host, port: api_port, path: request_url)
      perform_request(:post, uri, mail)
    end

    # Performs a GET request to the specified path
    # @param path [String] The request path
    # @return [Hash] The JSON response
    def get(path)
      uri = URI::HTTP.build(host: general_api_host, port: @api_port, path:)
      perform_request(:get, uri)
    end

    # Performs a POST request to the specified path
    # @param path [String] The request path
    # @param body [Hash] The request body
    # @return [Hash] The JSON response
    def post(path, body = nil)
      uri = URI::HTTP.build(host: general_api_host, port: @api_port, path:)
      perform_request(:post, uri, body)
    end

    # Performs a PATCH request to the specified path
    # @param path [String] The request path
    # @param body [Hash] The request body
    # @return [Hash] The JSON response
    def patch(path, body = nil)
      uri = URI::HTTP.build(host: general_api_host, port: @api_port, path:)
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
        body = json_response(response.body)
        raise Mailtrap::Error, body[:errors] || Array(body[:error])
      when Net::HTTPUnauthorized
        body = json_response(response.body)
        raise Mailtrap::AuthorizationError, body[:errors] || Array(body[:error])
      when Net::HTTPForbidden
        body = json_response(response.body)
        raise Mailtrap::RejectionError, body[:errors] || Array(body[:error])
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
  end
end
