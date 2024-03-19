# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module Mailtrap
  class Client
    SENDING_API_HOST = 'send.api.mailtrap.io'
    BULK_SENDING_API_HOST = 'send.api.mailtrap.io'
    SANDBOX_API_HOST = 'sandbox.api.mailtrap.io'
    API_PORT = 443

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
    def initialize(# rubocop:disable Metrics/ParameterLists
      api_key: ENV.fetch('MAILTRAP_API_KEY'),
      api_host: nil,
      api_port: API_PORT,
      bulk: false,
      sandbox: false,
      inbox_id: nil
    )
      raise ArgumentError, 'api_key is required' if api_key.nil?
      raise ArgumentError, 'api_port is required' if api_port.nil?

      api_host ||= select_api_host(bulk: bulk, sandbox: sandbox)
      raise ArgumentError, 'inbox_id is required for sandbox API' if sandbox && inbox_id.nil?

      @api_key = api_key
      @api_host = api_host
      @api_port = api_port
      @bulk = bulk
      @sandbox = sandbox
      @inbox_id = inbox_id
    end

    def send(mail)
      raise ArgumentError, 'should be Mailtrap::Mail::Base object' unless mail.is_a? Mail::Base

      request = post_request(request_url, mail.to_json)
      response = http_client.request(request)

      handle_response(response)
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

    def http_client
      @http_client ||= Net::HTTP.new(api_host, api_port).tap { |client| client.use_ssl = true }
    end

    def post_request(path, body)
      request = Net::HTTP::Post.new(path)
      request.body = body
      request['Authorization'] = "Bearer #{api_key}"
      request['Content-Type'] = 'application/json'
      request['User-Agent'] = 'mailtrap-ruby (https://github.com/railsware/mailtrap-ruby)'

      request
    end

    def handle_response(response) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      case response
      when Net::HTTPOK
        json_response(response.body)
      when Net::HTTPBadRequest
        raise Mailtrap::Error, json_response(response.body)[:errors]
      when Net::HTTPUnauthorized
        raise Mailtrap::AuthorizationError, json_response(response.body)[:errors]
      when Net::HTTPForbidden
        raise Mailtrap::RejectionError, json_response(response.body)[:errors]
      when Net::HTTPPayloadTooLarge
        raise Mailtrap::MailSizeError, ['message too large']
      when Net::HTTPTooManyRequests
        raise Mailtrap::RateLimitError, ['too many requests']
      when Net::HTTPClientError
        raise Mailtrap::Error, ['client error']
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
