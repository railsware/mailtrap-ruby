# frozen_string_literal: true

module Mailtrap
  # Data Transfer Object for Email Template Request
  #
  # For validation rules and field requirements, see the official API documentation:
  # @see https://api-docs.mailtrap.io/docs/mailtrap-api-docs/3295b60f19012-create-email-template
  #
  # @attr_reader name [String] The template name
  # @attr_reader category [String] The template category
  # @attr_reader subject [String] The email subject
  # @attr_reader body_text [String] The plain text content
  # @attr_reader body_html [String] The HTML content
  EmailTemplateRequest = Struct.new(:name, :category, :subject, :body_text, :body_html, keyword_init: true) do
    # @return [Hash] The template request attributes as a hash
    def to_h
      super.compact
    end
  end

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

  class EmailTemplatesAPI
    # @param account_id [Integer] The account ID
    # @param client [Mailtrap::Client] The client instance
    def initialize(account_id, client = Mailtrap::Client.new)
      @client = client
      @account_id = account_id
    end

    # Lists all email templates for the account
    # @return [Array<EmailTemplate>] Array of template objects
    # @raise [Mailtrap::Error] If the API request fails with a client or server error
    # @raise [Mailtrap::AuthorizationError] If the API key is invalid
    # @raise [Mailtrap::RejectionError] If the server refuses to process the request
    # @raise [Mailtrap::RateLimitError] If too many requests are made
    def list
      response = @client.get(base_path)
      response.map { |template| build_email_template(template) }
    end

    # Retrieves a specific email template
    # @param template_id [Integer] The template ID
    # @return [EmailTemplate] Template object
    # @raise [Mailtrap::Error] If the API request fails with a client or server error
    # @raise [Mailtrap::AuthorizationError] If the API key is invalid
    # @raise [Mailtrap::RejectionError] If the server refuses to process the request
    # @raise [Mailtrap::RateLimitError] If too many requests are made
    def get(template_id)
      response = @client.get("#{base_path}/#{template_id}")
      build_email_template(response)
    end

    # Creates a new email template
    # @param request [EmailTemplateRequest, Hash] The template request object or a hash with the same attributes
    # @return [EmailTemplate] Created template object
    # @raise [ArgumentError] If the request is invalid
    # @raise [Mailtrap::Error] If the API request fails with a client or server error
    # @raise [Mailtrap::AuthorizationError] If the API key is invalid
    # @raise [Mailtrap::RejectionError] If the server refuses to process the request
    # @raise [Mailtrap::RateLimitError] If too many requests are made
    def create(request)
      response = @client.post(base_path,
                              {
                                email_template: prepare_request(request)
                              })
      build_email_template(response)
    end

    # Updates an existing email template
    # @param template_id [Integer] The template ID
    # @param request [EmailTemplateRequest, Hash] The template request object or a hash with the same attributes
    # @return [EmailTemplate] Updated template object
    # @raise [ArgumentError] If the request is invalid
    # @raise [Mailtrap::Error] If the API request fails with a client or server error
    # @raise [Mailtrap::AuthorizationError] If the API key is invalid
    # @raise [Mailtrap::RejectionError] If the server refuses to process the request
    # @raise [Mailtrap::RateLimitError] If too many requests are made
    def update(template_id, request)
      response = @client.patch("#{base_path}/#{template_id}",
                               {
                                 email_template: prepare_request(request)
                               })
      build_email_template(response)
    end

    # Deletes an email template
    # @param template_id [Integer] The template ID
    # @return nil
    # @raise [Mailtrap::Error] If the API request fails with a client or server error
    # @raise [Mailtrap::AuthorizationError] If the API key is invalid
    # @raise [Mailtrap::RejectionError] If the server refuses to process the request
    # @raise [Mailtrap::RateLimitError] If too many requests are made
    def delete(template_id)
      @client.delete("#{base_path}/#{template_id}")
    end

    private

    def prepare_request(request)
      normalised = request.is_a?(EmailTemplateRequest) ? request : build_email_template_request(request)
      normalised.to_h
    end

    def build_email_template(options)
      EmailTemplate.new(options.slice(*EmailTemplate.members))
    end

    def build_email_template_request(options)
      EmailTemplateRequest.new(options.slice(*EmailTemplateRequest.members))
    end

    def base_path
      "/api/accounts/#{@account_id}/email_templates"
    end
  end
end
