# frozen_string_literal: true

module Mailtrap
  class EmailTemplates
    API_HOST = 'mailtrap.io'
    API_PORT = 443

    attr_reader :api_key, :api_host, :api_port

    def initialize(api_key:, api_host: API_HOST, api_port: API_PORT)
      raise ArgumentError, 'api_key is required' if api_key.nil?
      raise ArgumentError, 'api_port is required' if api_port.nil?

      @api_key = api_key
      @api_host = api_host
      @api_port = api_port
    end

    def all(account_id:)
      request(:get, "/api/accounts/#{account_id}/email_templates")
    end

    def create(account_id:, **params)
      request(:post, "/api/accounts/#{account_id}/email_templates", params)
    end

    def update(account_id:, email_template_id:, **params)
      request(
        :patch,
        "/api/accounts/#{account_id}/email_templates/#{email_template_id}",
        params
      )
    end

    def delete(account_id:, email_template_id:)
      request(:delete, "/api/accounts/#{account_id}/email_templates/#{email_template_id}")
      true
    end

    private

    def http_client
      @http_client ||= Net::HTTP.new(api_host, api_port).tap { |client| client.use_ssl = true }
    end

    def request(http_method, path, body = nil) # rubocop:disable Metrics/MethodLength
      request_class = {
        get: Net::HTTP::Get,
        post: Net::HTTP::Post,
        patch: Net::HTTP::Patch,
        delete: Net::HTTP::Delete
      }.fetch(http_method)

      request = request_class.new(path)
      request['Authorization'] = "Bearer #{api_key}"
      request['User-Agent'] = 'mailtrap-ruby (https://github.com/railsware/mailtrap-ruby)'
      if body
        request['Content-Type'] = 'application/json'
        request.body = JSON.generate(body)
      end

      response = http_client.request(request)
      handle_response(response)
    end # rubocop:enable Metrics/MethodLength

    def handle_response(response) # rubocop:disable Metrics/MethodLength
      case response
      when Net::HTTPNoContent
        true
      when Net::HTTPSuccess
        json_response(response.body)
      when Net::HTTPUnauthorized
        raise Mailtrap::AuthorizationError, json_response(response.body)[:errors]
      when Net::HTTPForbidden
        raise Mailtrap::RejectionError, json_response(response.body)[:errors]
      when Net::HTTPClientError, Net::HTTPServerError
        raise Mailtrap::Error, json_response(response.body)[:errors]
      else
        raise Mailtrap::Error, ["unexpected status code=#{response.code}"]
      end
    end # rubocop:enable Metrics/MethodLength

    def json_response(body)
      return {} if body.nil? || body.empty?

      JSON.parse(body, symbolize_names: true)
    end
  end
end
