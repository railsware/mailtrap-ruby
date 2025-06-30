# frozen_string_literal: true

module Mailtrap
  # Data Transfer Object for Suppression
  # @see https://api-docs.mailtrap.io/docs/mailtrap-api-docs/f8144826d885a-list-and-search-suppressions
  # @attr_reader id [String] The suppression UUID
  # @attr_reader type [String] The suppression type
  # @attr_reader created_at [String] The creation timestamp
  # @attr_reader email [String] The email address
  # @attr_reader sending_stream [String] The sending stream
  # @attr_reader domain_name [String, nil] The domain name
  # @attr_reader message_bounce_category [String, nil] The bounce category
  # @attr_reader message_category [String, nil] The message category
  # @attr_reader message_client_ip [String, nil] The client IP
  # @attr_reader message_created_at [String, nil] The message creation timestamp
  # @attr_reader message_esp_response [String, nil] The ESP response
  # @attr_reader message_esp_server_type [String, nil] The ESP server type
  # @attr_reader message_outgoing_ip [String, nil] The outgoing IP
  # @attr_reader message_recipient_mx_name [String, nil] The recipient MX name
  # @attr_reader message_sender_email [String, nil] The sender email
  # @attr_reader message_subject [String, nil] The message subject
  Suppression = Struct.new(
    :id,
    :type,
    :created_at,
    :email,
    :sending_stream,
    :domain_name,
    :message_bounce_category,
    :message_category,
    :message_client_ip,
    :message_created_at,
    :message_esp_response,
    :message_esp_server_type,
    :message_outgoing_ip,
    :message_recipient_mx_name,
    :message_sender_email,
    :message_subject,
    keyword_init: true
  ) do
    # @return [Hash] The suppression attributes as a hash
    def to_h
      super.compact
    end
  end
end
