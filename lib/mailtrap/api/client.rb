# frozen_string_literal: true
require 'json'
require 'net/http'
require 'uri'

module Mailtrap
  module Api
    class Client
      BASE_HOST = 'sandbox.api.mailtrap.io'
      BASE_PORT = 443

      def initialize(token:, host: BASE_HOST, port: BASE_PORT)
        @token = token
        @host = host
        @port = port
      end

      def get(path, params: {})
        uri = URI::HTTPS.build(host: @host, path: path, query: URI.encode_www_form(params))
        request = Net::HTTP::Get.new(uri)
        attach_headers(request)
        perform_request(uri, request)
      end

      def post(path, body: {})
        uri = URI::HTTPS.build(host: @host, path: path)
        request = Net::HTTP::Post.new(uri)
        request.body = JSON.dump(body)
        attach_headers(request)
        perform_request(uri, request)
      end

      def patch(path, body: {})
        uri = URI::HTTPS.build(host: @host, path: path)
        request = Net::HTTP::Patch.new(uri)
        request.body = JSON.dump(body)
        attach_headers(request)
        perform_request(uri, request)
      end      

      def delete(path)
        uri = URI::HTTPS.build(host: @host, path: path)
        request = Net::HTTP::Delete.new(uri)
        attach_headers(request)
        perform_request(uri, request)
      end

      def batch_send(payload)
        post('/api/send/batch', body: payload)
      end

      private

      def attach_headers(request)
        request['Authorization'] = "Bearer #{@token}"
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
      
    end
  end
end