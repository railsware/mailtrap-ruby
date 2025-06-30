# frozen_string_literal: true

require_relative 'email_template'

module Mailtrap
  class EmailTemplatesAPI < BaseAPI
    SUPPORTED_OPTIONS = %i[name subject category body_html body_text].freeze
    private_constant :SUPPORTED_OPTIONS

    # Lists all email templates for the account
    # @return [Array<EmailTemplate>] Array of template objects
    # @!macro api_errors
    def list
      response = client.get(base_path)
      response.map { |template| build_entity(template, EmailTemplate) }
    end

    # Retrieves a specific email template
    # @param template_id [Integer] The template ID
    # @return [EmailTemplate] Template object
    # @!macro api_errors
    def get(template_id)
      response = client.get("#{base_path}/#{template_id}")
      build_entity(response, EmailTemplate)
    end

    # Creates a new email template
    # @param [Hash] options The parameters to create
    # @option options [String] :name The template name
    # @option options [String] :subject The email subject
    # @option options [String] :category The template category
    # @option options [String, nil] :body_html The HTML content. Default: nil.
    # @option options [String, nil] :body_text The plain text content. Default: nil.
    # @return [EmailTemplate] Created template object
    # @!macro api_errors
    # @raise [ArgumentError] If invalid options are provided
    def create(options)
      validate_options!(options, SUPPORTED_OPTIONS)

      response = client.post(base_path, email_template: options)
      build_entity(response, EmailTemplate)
    end

    # Updates an existing email template
    # @param template_id [Integer] The template ID
    # @param [Hash] options The parameters to update
    # @option options [String] :name The template name
    # @option options [String] :subject The email subject
    # @option options [String] :category The template category
    # @option options [String, nil] :body_html The HTML content
    # @option options [String, nil] :body_text The plain text content
    # @return [EmailTemplate] Updated template object
    # @!macro api_errors
    # @raise [ArgumentError] If invalid options are provided
    def update(template_id, options)
      validate_options!(options, SUPPORTED_OPTIONS)

      response = client.patch("#{base_path}/#{template_id}", email_template: options)
      build_entity(response, EmailTemplate)
    end

    # Deletes an email template
    # @param template_id [Integer] The template ID
    # @return nil
    # @!macro api_errors
    def delete(template_id)
      client.delete("#{base_path}/#{template_id}")
    end

    private

    def base_path
      "/api/accounts/#{account_id}/email_templates"
    end
  end
end
