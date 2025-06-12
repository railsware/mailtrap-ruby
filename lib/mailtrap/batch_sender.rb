# frozen_string_literal: true

module Mailtrap
  class BatchSender
    def initialize(api_client)
      @client = api_client
    end

    def send_emails(base:, requests:)
      validate_client_host!
      base_payload = ensure_hash(base).transform_keys(&:to_sym).except(:to, :cc, :bcc)
      validate_requests!(requests)

      payload = { base: base_payload, requests: }
      response = @client.batch_send(payload)

      unless response.is_a?(Hash) && response[:responses].is_a?(Array)
        raise Mailtrap::InvalidApiResponseError.new(['Unexpected batch_send response format']),
              "[Mailtrap] #{response.inspect}"
      end

      response
    end

    private

    def validate_client_host!
      return if @client.api_host.include?('bulk.api.mailtrap.io')

      raise ArgumentError, '[Mailtrap] batch_send must use bulk.api.mailtrap.io'
    end

    def ensure_hash(obj)
      return obj.as_json if obj.respond_to?(:as_json)
      return obj if obj.is_a?(Hash)

      raise ArgumentError, "Expected Hash or object with #as_json, got #{obj.class}"
    end

    def validate_requests!(requests)
      raise ArgumentError, 'Requests must be a non-empty Array' unless requests.is_a?(Array) && requests.any?
      raise ArgumentError, 'Too many messages in batch: max 500 allowed' if requests.size > 500

      requests.each_with_index do |request, index|
        validate_recipients!(request, index)
      end
    end

    def validate_recipients!(request, index)
      %i[to cc bcc].each do |field|
        next unless request[field].is_a?(Array)

        request[field].compact.each do |recipient|
          Mailtrap::Validators::EmailValidator.validate!(
            recipient[:email],
            field_name: "#{field}[:email] in request ##{index + 1}"
          )
        rescue ArgumentError => e
          raise ArgumentError, e.message
        end
      end
    end
  end
end