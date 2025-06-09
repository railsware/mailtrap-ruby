# frozen_string_literal: true

module Mailtrap
  class Contact
    ALLOWED_CREATE_KEYS = %i[email fields list_ids].freeze
    ALLOWED_UPDATE_KEYS = %i[
      email fields list_ids_included list_ids_excluded unsubscribed
    ].freeze

    EXPECTED_KEYS = %i[
      id status email fields list_ids created_at updated_at
    ].freeze

    def initialize(api_client, strict_mode: false)
      @client = api_client
      @strict_mode = strict_mode
    end

    def list(account_id:, page: 1, per_page: 50)
      response = @client.get("/api/accounts/#{account_id}/contacts", params: {
        page: page,
        per_page: per_page
      })
      validate_response_keys!(response[:data]) if @strict_mode
      response
    end

    def find(account_id:, contact_id:)
      response = @client.get("/api/accounts/#{account_id}/contacts/#{contact_id}")
      validate_response_keys!([response]) if @strict_mode
      response
    end

    def create(account_id:, **attrs)
      validate_keys!(attrs, ALLOWED_CREATE_KEYS)
      @client.post("/api/accounts/#{account_id}/contacts", body: {
        contact: attrs
      })
    end

    def update(account_id:, contact_id:, **attrs)
      validate_keys!(attrs, ALLOWED_UPDATE_KEYS)
      @client.patch("/api/accounts/#{account_id}/contacts/#{contact_id}", body: {
        contact: attrs.compact
      })
    end

    def delete(account_id:, contact_id:)
      @client.delete("/api/accounts/#{account_id}/contacts/#{contact_id}")
    end

    private

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
          raise ArgumentError, "Unexpected key in response: #{key}" unless EXPECTED_KEYS.include?(key)
        end

        EXPECTED_KEYS.each do |key|
          raise ArgumentError, "Missing key in contact object: #{key}" unless record.key?(key)
        end
      end
    end
  end
end
