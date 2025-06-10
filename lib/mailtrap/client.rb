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

    def initialize( # rubocop:disable Metrics/ParameterLists
      api_key: ENV.fetch('MAILTRAP_API_KEY'),
      api_host: nil,
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

    def get(path, params: {})
      uri = URI::HTTPS.build(host: api_host, path: path, query: URI.encode_www_form(params))
      request = Net::HTTP::Get.new(uri)
      attach_headers(request)
      perform_request(uri, request)
    end

    def post(path, body: {})
      uri = URI::HTTPS.build(host: api_host, path: path)
      request = Net::HTTP::Post.new(uri)
      request.body = JSON.dump(body)
      attach_headers(request)
      perform_request(uri, request)
    end

    def patch(path, body: {})
      uri = URI::HTTPS.build(host: api_host, path: path)
      request = Net::HTTP::Patch.new(uri)
      request.body = JSON.dump(body)
      attach_headers(request)
      perform_request(uri, request)
    end

    def delete(path)
      uri = URI::HTTPS.build(host: api_host, path: path)
      request = Net::HTTP::Delete.new(uri)
      attach_headers(request)
      perform_request(uri, request)
    end

    def batch_send(payload)
      post('/api/send/batch', body: payload)
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
      attach_headers(request)
      request
    end

    def attach_headers(request)
      request['Authorization'] = "Bearer #{api_key}"
      request['Content-Type'] = 'application/json'
      request['User-Agent'] = 'mailtrap-ruby (https://github.com/railsware/mailtrap-ruby)'
    end

    def perform_request(uri, request)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.request(request)

      unless response.is_a?(Net::HTTPSuccess)
        warn "[Mailtrap] Request failed: #{response.code} #{response.body}"
        raise "Mailtrap API Error (#{response.code}): #{response.body}"
      end

      body = JSON.parse(response.body, symbolize_names: true)

      if body.is_a?(Hash) && body[:errors]
        warn "[Mailtrap] API errors in response: #{body[:errors]}"
      end

      body
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
