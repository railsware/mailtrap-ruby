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

    attr_reader :api_key, :api_host, :api_port, :bulk, :sandbox, :inbox_id

    def initialize(api_key: ENV.fetch('MAILTRAP_API_KEY'), api_host: nil, api_port: API_PORT, bulk: false, sandbox: false, inbox_id: nil)
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
    end

    def send(mail)
      raise ArgumentError, 'should be Mailtrap::Mail::Base object' unless mail.is_a? Mail::Base

      request = post_request(request_url, mail.to_json)
      response = http_client(cache: true).request(request)
      handle_response(response)
    end

    def get(path, params: {})
      request(:get, path, params: params)
    end
    
    def post(path, body: {})
      request(:post, path, body: body)
    end
    
    def patch(path, body: {})
      request(:patch, path, body: body)
    end
    
    def delete(path)
      request(:delete, path)
    end

    def batch_send(payload)
      post('/api/batch', body: payload)
    end

    def request(method, path, body: nil, params: nil)
      uri = URI::HTTPS.build(
        host: api_host,
        path: path,
        query: params ? URI.encode_www_form(params) : nil
      )
    
      request = build_request(method, uri, body)
      perform_request(uri, request)
    end
    
    def build_request(method, uri, body)
      request_class = {
        get: Net::HTTP::Get,
        post: Net::HTTP::Post,
        patch: Net::HTTP::Patch,
        delete: Net::HTTP::Delete
      }[method.to_sym] || raise(ArgumentError, "Unsupported method: #{method}")
    
      request = request_class.new(uri)

      if [:post, :patch].include?(method.to_sym) && body
        request.body = JSON.dump(body)
      end
    
      attach_headers(request)
      request
    end

    private

    def select_api_host(bulk:, sandbox:)
      raise ArgumentError, 'bulk mode is not applicable for sandbox API' if bulk && sandbox

      return SANDBOX_API_HOST if sandbox
      return BULK_SENDING_API_HOST if bulk
      SENDING_API_HOST
    end

    def request_url
      "/api/send#{sandbox ? "/#{inbox_id}" : ''}"
    end

    def http_client(cache: true)
      return @http_client if cache && defined?(@http_client)

      Net::HTTP.new(api_host, api_port).tap { |client| client.use_ssl = true }
    end

    def post_request(path, body)
      request = Net::HTTP::Post.new(path)
      request.body = body
      attach_headers(request)
      request
    end

    def attach_headers(request)
      request['Authorization'] = "Bearer #{api_key}"
      request['Content-Type'] = 'application/json'
      request['User-Agent'] = 'mailtrap-ruby (https://github.com/railsware/mailtrap-ruby)'
    end

    def perform_request(uri, request)
      client = http_client(cache: false)
      response = client.request(request)
      handle_response(response)
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