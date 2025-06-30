# frozen_string_literal: true

module Mailtrap
  # Data Transfer Object for Email Template
  #
  # For field descriptions and response format, see the official API documentation:
  # @see https://api-docs.mailtrap.io/docs/mailtrap-api-docs/9e5914d89c481-email-template
  #
  # @attr_reader id [Integer] The template ID
  # @attr_reader uuid [String] The template UUID
  # @attr_reader name [String] The template name
  # @attr_reader subject [String] The email subject
  # @attr_reader category [String] The template category
  # @attr_reader body_html [String] The HTML content
  # @attr_reader body_text [String] The plain text content
  # @attr_reader created_at [String] The creation timestamp
  # @attr_reader updated_at [String] The last update timestamp
  EmailTemplate = Struct.new(
    :id,
    :uuid,
    :name,
    :subject,
    :category,
    :body_html,
    :body_text,
    :created_at,
    :updated_at,
    keyword_init: true
  ) do
    # @return [Hash] The template attributes as a hash
    def to_h
      super.compact
    end
  end
end
