# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module Mailtrap
  class Client
    SENDING_API_HOST = 'send.api.mailtrap.io'
    BULK_SENDING_API_HOST = 'bulk.api.mailtrap.io'
    SANDBOX_API_HOST = 'sandbox.api.mailtrap.io'
    GENERAL_API_HOST = 'mailtrap.io'
    API_PORT = 443

    attr_reader :api_key, :api_host, :general_api_host, :api_port, :bulk, :sandbox, :inbox_id

    # Initializes a new Mailtrap::Client instance.
    #
    # @param [String] api_key The Mailtrap API key to use for sending. Required.
    #   If not set, it is taken from the MAILTRAP_API_KEY environment variable.
    # @param [String] api_host The Mailtrap API hostname. If not set, it is chosen internally.
    # @param [String] general_api_host The Mailtrap general API hostname for non-sending operations.
    # @param [Integer] api_port The Mailtrap API port. Default: 443.
    # @param [Boolean] bulk Whether to use the Mailtrap bulk sending API. Default: false.
    #   If enabled, it is incompatible with `sandbox: true`.
    # @param [Boolean] sandbox Whether to use the Mailtrap sandbox API. Default: false.
    #   If enabled, it is incompatible with `bulk: true`.
    # @param [Integer] inbox_id The sandbox inbox ID to send to. Required if sandbox API is used.
    # @raise [ArgumentError] If api_key or api_port is nil, or if sandbox is true but inbox_id is nil,
    #   or if incompatible options are provided.
    def initialize( # rubocop:disable Metrics/ParameterLists
      api_key: ENV.fetch('MAILTRAP_API_KEY'),
      api_host: nil,
      general_api_host: GENERAL_API_HOST,
      api_port: API_PORT,
      bulk: false,
      sandbox: false,
      inbox_id: nil
    )
      raise ArgumentError, 'api_key is required' if api_key.nil?
      raise ArgumentError, 'api_port is required' if api_port.nil?

      api_host ||= select_api_host(bulk:, sandbox:)
      raise ArgumentError, 'inbox_id is required for sandbox API' if sandbox && inbox_id.nil?

      @api_key = api_key
      @api_host = api_host
      @general_api_host = general_api_host
      @api_port = api_port
      @bulk = bulk
      @sandbox = sandbox
      @inbox_id = inbox_id
      @http_clients = {}
    end

    # Sends an email
    # @example
    #   mail = Mailtrap::Mail.from_template(
    #     from: { email: 'mailtrap@example.com', name: 'Mailtrap Test' },
    #     to: [
    #       { email: 'your@email.com' }
    #     ],
    #     template_uuid: '2f45b0aa-bbed-432f-95e4-e145e1965ba2',
    #     template_variables: {
    #       'user_name' => 'John Doe'
    #     }
    #   )
    #   client.send(mail)
    # @example
    #   client.send(
    #     from: { email: 'mailtrap@example.com', name: 'Mailtrap Test' },
    #     to: [
    #       { email: 'your@email.com' }
    #     ],
    #     subject: 'You are awesome!',
    #     text: 'Congrats for sending test email with Mailtrap!'
    #   )
    # @param mail [#to_json] The email to send
    # @return [Hash] The JSON response
    # @!macro api_errors
    # @raise [Mailtrap::MailSizeError] If the message is too large
    def send(mail)
      perform_request(:post, api_host, send_path, mail)
    end

    # Performs a GET request to the specified path
    # @param path [String] The request path
    # @return [Hash, nil] The JSON response
    # @!macro api_errors
    def get(path)
      perform_request(:get, general_api_host, path)
    end

    # Performs a POST request to the specified path
    # @param path [String] The request path
    # @param body [Hash] The request body
    # @return [Hash, nil] The JSON response
    # @!macro api_errors
    def post(path, body = nil)
      perform_request(:post, general_api_host, path, body)
    end

    # Performs a PATCH request to the specified path
    # @param path [String] The request path
    # @param body [Hash] The request body
    # @return [Hash, nil] The JSON response
    # @!macro api_errors
    def patch(path, body = nil)
      perform_request(:patch, general_api_host, path, body)
    end

    # Performs a DELETE request to the specified path
    # @param path [String] The request path
    # @return [Hash, nil] The JSON response
    # @!macro api_errors
    def delete(path)
      perform_request(:delete, general_api_host, path)
    end

    private

    def http_client_for(host)
      @http_clients[host] ||= Net::HTTP.new(host, api_port).tap { |client| client.use_ssl = true }
    end

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

    def send_path
      "/api/send#{sandbox ? "/#{inbox_id}" : ""}"
    end

    def perform_request(method, host, path, body = nil)
      http_client = http_client_for(host)
      request = setup_request(method, path, body)
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

    def handle_response(response) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
      case response
      when Net::HTTPOK, Net::HTTPCreated
        json_response(response.body)
      when Net::HTTPNoContent
        nil
      when Net::HTTPBadRequest
        raise Mailtrap::Error, ['bad request'] if response.body.empty?

        raise Mailtrap::Error, response_errors(response.body)
      when Net::HTTPUnauthorized
        raise Mailtrap::AuthorizationError, response_errors(response.body)
      when Net::HTTPForbidden
        raise Mailtrap::RejectionError, response_errors(response.body)
      when Net::HTTPPayloadTooLarge
        raise Mailtrap::MailSizeError, ['message too large']
      when Net::HTTPTooManyRequests
        raise Mailtrap::RateLimitError, ['too many requests']
      when Net::HTTPClientError
        raise Mailtrap::Error, ["client error '#{response.body}'"]
      when Net::HTTPServerError
        raise Mailtrap::Error, ['server error']
      else
        raise Mailtrap::Error, ["unexpected status code=#{response.code}"]
      end
    end

    def response_errors(body)
      parsed_body = json_response(body)
      Array(parsed_body[:errors] || parsed_body[:error])
    end

    def json_response(body)
      JSON.parse(body, symbolize_names: true)
    end
  end
end
