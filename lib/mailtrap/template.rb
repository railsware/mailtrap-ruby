# frozen_string_literal: true

module Mailtrap
  class Template
    ALLOWED_CREATE_KEYS = %i[name subject category body_html body_text].freeze
    ALLOWED_UPDATE_KEYS = ALLOWED_CREATE_KEYS
    ALLOWED_RESPONSE_KEYS = %i[
      id uuid name subject category body_html body_text created_at updated_at
    ].freeze

    def initialize(api_client, strict_mode: false)
      @client = api_client
      @strict_mode = strict_mode
    end

    def list(account_id:, page: 1, per_page: 50)
      response = @client.get("/api/accounts/#{account_id}/email_templates", params: {
        page: page,
        per_page: per_page
      })
    
      validate_response_keys!(response[:data]) if @strict_mode
      response
    end

    def find(account_id:, template_id:)
      response = @client.get("/api/accounts/#{account_id}/email_templates/#{template_id}")
      validate_response_keys!([response]) if @strict_mode
      response
    end

    def create(account_id:, **attrs)
      validate_keys!(attrs, ALLOWED_CREATE_KEYS)

      @client.post("/api/accounts/#{account_id}/email_templates", body: {
        email_template: attrs
      })
    end

    def patch(account_id:, template_id:, **attrs)
      validate_keys!(attrs, ALLOWED_UPDATE_KEYS)

      @client.patch("/api/accounts/#{account_id}/email_templates/#{template_id}", body: {
        email_template: attrs.compact
      })
    end

    def delete(account_id:, template_id:)
      @client.delete("/api/accounts/#{account_id}/email_templates/#{template_id}")
    end

    private

    EXPECTED_KEYS = %i[id uuid name subject category body_html body_text created_at updated_at].freeze

    def validate_keys!(input, allowed_keys)
      return unless @strict_mode

      input.each_key do |key|
        unless allowed_keys.include?(key)
          raise ArgumentError, "Unexpected key in payload: #{key}"
        end
      end
    end

    def validate_response_keys!(records)
      records.each do |record|
        record.each_key do |key|
          unless EXPECTED_KEYS.include?(key)
            raise ArgumentError, "Unexpected key in response: #{key}"
          end
        end
    
        EXPECTED_KEYS.each do |key|
          unless record.key?(key)
            raise ArgumentError, "Missing key in template object: #{key}"
          end
        end
      end
    end
  end
end