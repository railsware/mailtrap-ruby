# frozen_string_literal: true

module Mailtrap
  module Resources
    class BatchSender
      REQUIRED_BASE_KEYS = %i[from subject].freeze
      OPTIONAL_BASE_KEYS = %i[
        reply_to text category headers attachments html template_uuid
        track_opens track_clicks
      ].freeze      
      ALLOWED_BASE_KEYS = (REQUIRED_BASE_KEYS + OPTIONAL_BASE_KEYS).freeze

      ALLOWED_REQUEST_KEYS = %i[
        to cc bcc custom_variables template_variables template_uuid
      ].freeze

      REQUIRED_FROM_KEYS = %i[email].freeze
      OPTIONAL_FROM_KEYS = %i[name].freeze
      ALLOWED_FROM_KEYS = (REQUIRED_FROM_KEYS + OPTIONAL_FROM_KEYS).freeze

      REQUIRED_TO_KEYS = %i[email].freeze
      OPTIONAL_TO_KEYS = %i[name].freeze
      ALLOWED_TO_KEYS = (REQUIRED_TO_KEYS + OPTIONAL_TO_KEYS).freeze

      def initialize(api_client, strict_mode: true)
        @client = api_client
        @strict = strict_mode
      end

      def send_emails(base:, requests:)
        validate_base!(base)
        validate_requests!(requests)
        payload = { base: base, requests: requests }
        @client.batch_send(payload)
      end

      private

      def validate_base!(base)
        raise ArgumentError, "Base must be a Hash" unless base.is_a?(Hash)

        if base[:attachments]
          total_size = 0
        
          base[:attachments].each_with_index do |attachment, i|
            raise ArgumentError, "Attachment ##{i + 1} must be a Hash" unless attachment.is_a?(Hash)
            raise ArgumentError, "Attachment ##{i + 1} missing 'filename'" unless attachment[:filename]
            raise ArgumentError, "Attachment ##{i + 1} missing 'content'" unless attachment[:content]
        
            total_size += attachment[:content].bytesize if attachment[:content].is_a?(String)
          end
        
          if total_size > 50 * 1024 * 1024
            raise ArgumentError, "Attachments exceed maximum allowed size (50MB)"
          end
        end

        REQUIRED_BASE_KEYS.each do |key|
          raise ArgumentError, "Missing required base field: #{key}" unless base.key?(key)
        end

        if @strict
          base.each_key do |key|
            raise ArgumentError, "Unexpected key in base: #{key}" unless ALLOWED_BASE_KEYS.include?(key)
          end
        end

        from = base[:from]
        raise ArgumentError, "Base 'from' must be a Hash" unless from.is_a?(Hash)

        REQUIRED_FROM_KEYS.each do |key|
          raise ArgumentError, "Missing 'from' field: #{key}" unless from.key?(key)
        end

        if @strict
          from.each_key do |key|
            raise ArgumentError, "Unexpected key in from: #{key}" unless ALLOWED_FROM_KEYS.include?(key)
          end
        end
      end

      def validate_requests!(requests)
        raise ArgumentError, "Requests must be an Array" unless requests.is_a?(Array)
        raise ArgumentError, "Requests array must not be empty" if requests.empty?

        if requests.size > 500
          raise ArgumentError, "Too many messages in batch: max 500 allowed"
        end

        requests.each_with_index do |request, index|
          %i[to cc bcc].each do |field|
            next unless request[field]

            recipients = request[field]
            unless recipients.is_a?(Array) && recipients.all? { |r| r[:email].to_s.match?(/@/) }
              raise ArgumentError, "Invalid #{field} in request ##{index + 1}"
            end

            recipients.each do |recipient|
              REQUIRED_TO_KEYS.each do |key|
                raise ArgumentError, "Missing #{field}[:#{key}] in request ##{index + 1}" unless recipient.key?(key)
              end

              if @strict
                recipient.each_key do |key|
                  raise ArgumentError, "Unexpected key in #{field} recipient: #{key}" unless ALLOWED_TO_KEYS.include?(key)
                end
              end
            end
          end

          if @strict
            request.each_key do |key|
              raise ArgumentError, "Unexpected key in request ##{index + 1}: #{key}" unless ALLOWED_REQUEST_KEYS.include?(key)
            end
          end
        end
      end
    end
  end
end
