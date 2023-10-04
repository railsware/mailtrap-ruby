# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module Mailtrap
  module Sending
    class Client
      API_HOST = 'send.api.mailtrap.io'
      API_PORT = 443

      attr_reader :api_key, :api_host, :api_port

      def initialize(api_key: ENV.fetch('MAILTRAP_API_KEY'), api_host: API_HOST, api_port: API_PORT)
        @api_key = api_key
        @api_host = api_host
        @api_port = api_port
      end

      def send(mail)
        raise ArgumentError, 'should be Mailtrap::Mail::Base object' unless mail.is_a? Mail::Base

        request = post_request('/api/send', mail.to_json)
        response = http_client.request(request)

        handle_response(response)
      end

      private

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
          raise Mailtrap::Sending::Error, json_response(response.body)[:errors]
        when Net::HTTPUnauthorized
          raise Mailtrap::Sending::AuthorizationError, json_response(response.body)[:errors]
        when Net::HTTPForbidden
          raise Mailtrap::Sending::RejectionError, json_response(response.body)[:errors]
        when Net::HTTPPayloadTooLarge
          raise Mailtrap::Sending::MailSizeError, ['message too large']
        when Net::HTTPTooManyRequests
          raise Mailtrap::Sending::RateLimitError, ['too many requests']
        when Net::HTTPClientError
          raise Mailtrap::Sending::Error, ['client error']
        when Net::HTTPServerError
          raise Mailtrap::Sending::Error, ['server error']
        else
          raise Mailtrap::Sending::Error, ["unexpected status code=#{response.code}"]
        end
      end

      def json_response(body)
        JSON.parse(body, symbolize_names: true)
      end
    end
  end
end
