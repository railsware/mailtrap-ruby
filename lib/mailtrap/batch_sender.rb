# frozen_string_literal: true

module Mailtrap
  class BatchSender
    def initialize(api_client)
      @client = api_client
    end

    def send_emails(base:, requests:)
      unless @client.api_host == Mailtrap::Client::BULK_SENDING_API_HOST
        raise ArgumentError, "[Mailtrap] batch_send must use bulk.api.mailtrap.io"
      end
    
      base_payload = ensure_hash(base)
      validate_base!(base_payload)
      validate_requests!(requests)
    
      payload = { base: base_payload, requests: requests }
      response = @client.batch_send(payload)

      unless response.is_a?(Hash) && response[:responses].is_a?(Array)
        raise Mailtrap::Error.new(['Unexpected batch_send response format']), "[Mailtrap] #{response.inspect}"
      end

      response
    end

    private

    def ensure_hash(obj)
      return obj.as_json if obj.respond_to?(:as_json)
      return obj if obj.is_a?(Hash)
      raise ArgumentError, "Expected Hash or object with #as_json, got #{obj.class}"
    end

    def validate_base!(base)
      from = base[:from]
      unless from.is_a?(Hash) && from[:email].is_a?(String) && from[:email].match?(/@/)
        raise ArgumentError, "Base 'from[:email]' must be a valid email"
      end
    end

    def validate_requests!(requests)
      raise ArgumentError, "Requests must be a non-empty Array" unless requests.is_a?(Array) && requests.any?
      raise ArgumentError, "Too many messages in batch: max 500 allowed" if requests.size > 500

      requests.each_with_index do |request, index|
        %i[to cc bcc].each do |field|
          next unless request[field].is_a?(Array)

          request[field].each do |recipient|
            email = recipient[:email]
            unless email.is_a?(String) && email.match?(/@/)
              raise ArgumentError, "Invalid #{field}[:email] in request ##{index + 1}"
            end
          end
        end
      end
    end
  end
end