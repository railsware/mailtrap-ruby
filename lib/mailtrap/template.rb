# frozen_string_literal: true

module Mailtrap
  # Data Transfer Object for Email Template Request
  # @attr_reader name [String] The template name (required, <= 255 chars)
  # @attr_reader category [String] The template category (required, <= 255 chars)
  # @attr_reader subject [String] The email subject (required, <= 255 chars)
  # @attr_reader body_text [String] The plain text content (<= 10000000 chars)
  # @attr_reader body_html [String] The HTML content (<= 10000000 chars)
  EmailTemplateRequest = Struct.new(:name, :category, :subject, :body_text, :body_html, keyword_init: true) do
    def initialize(*)
      super
      validate_required_fields
      validate_field_lengths
    end

    # @return [Hash] The template request attributes as a hash
    def to_h
      super.compact
    end

    private

    def validate_required_fields
      required_fields = %i[name category subject]
      missing_fields = required_fields.select { |field| self[field].nil? || self[field].empty? }

      return if missing_fields.empty?

      raise ArgumentError, "Missing required fields: #{missing_fields.join(", ")}"
    end

    def validate_field_lengths
      validate_field_length(:name, name, Template::MAX_LENGTH)
      validate_field_length(:category, category, Template::MAX_LENGTH)
      validate_field_length(:subject, subject, Template::MAX_LENGTH)
      validate_field_length(:body_text, body_text, Template::MAX_BODY_LENGTH)
      validate_field_length(:body_html, body_html, Template::MAX_BODY_LENGTH)
    end

    def validate_field_length(field, value, max_length)
      return if value.nil? || value.length <= max_length

      raise ArgumentError, "#{field} exceeds maximum length of #{max_length} characters"
    end
  end

  # Data Transfer Object for Email Template
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

  class Template
    MAX_LENGTH = 255
    MAX_BODY_LENGTH = 10_000_000

    # @param account_id [Integer] The account ID
    # @param client [Mailtrap::Client] The client instance
    def initialize(account_id, client = Mailtrap::Client.new)
      @client = client
      @account_id = account_id
    end

    # Lists all email templates for the account
    # @return [Array<EmailTemplate>] Array of template objects
    def list
      response = @client.get(base_path)
      response.map { |template| EmailTemplate.new(template) }
    end

    # Retrieves a specific email template
    # @param template_id [Integer] The template ID
    # @return [EmailTemplate] Template object
    def get(template_id)
      response = @client.get("#{base_path}/#{template_id}")
      EmailTemplate.new(response)
    end

    # Creates a new email template
    # @param request [EmailTemplateRequest, Hash] The template request object or a hash with the same attributes
    # @return [EmailTemplate] Created template object
    # @raise [ArgumentError] If the request is invalid
    def create(request)
      response = @client.post(base_path,
                              {
                                email_template: request.to_h
                              })
      EmailTemplate.new(response)
    end

    # Updates an existing email template
    # @param template_id [Integer] The template ID
    # @param request [EmailTemplateRequest, Hash] The template request object or a hash with the same attributes
    # @return [EmailTemplate] Updated template object
    # @raise [ArgumentError] If the request is invalid
    def update(template_id, request)
      response = @client.patch("#{base_path}/#{template_id}",
                               {
                                 email_template: request.to_h
                               })
      EmailTemplate.new(response)
    end

    # Deletes an email template
    # @param template_id [Integer] The template ID
    # @return [Boolean] true if successful
    def delete(template_id)
      @client.delete("#{base_path}/#{template_id}")
    end

    private

    def base_path
      "/api/accounts/#{@account_id}/email_templates"
    end
  end
end
