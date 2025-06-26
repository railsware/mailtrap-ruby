# frozen_string_literal: true

module Mailtrap
  class EmailTemplatesAPI
    attr_reader :client, :account_id

    SUPPORTED_OPTIONS = %i[name subject category body_html body_text].freeze

    # @param account_id [Integer] The account ID
    # @param client [Mailtrap::Client] The client instance
    # @raise [ArgumentError] If account_id is nil
    def initialize(account_id = ENV.fetch('MAILTRAP_ACCOUNT_ID'), client = Client.new)
      raise ArgumentError, 'account_id is required' if account_id.to_i.zero?

      @account_id = account_id
      @client = client
    end

    # Lists all email templates for the account
    # @return [Array<EmailTemplate>] Array of template objects
    # @!macro api_errors
    def list
      response = client.get(base_path)
      response.map { |template| build_email_template(template) }
    end

    # Retrieves a specific email template
    # @param template_id [Integer] The template ID
    # @return [EmailTemplate] Template object
    # @!macro api_errors
    def get(template_id)
      response = client.get("#{base_path}/#{template_id}")
      build_email_template(response)
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
      validate_options(options)

      response = client.post(base_path, email_template: options)
      build_email_template(response)
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
      validate_options(options)

      response = client.patch("#{base_path}/#{template_id}", email_template: options)
      build_email_template(response)
    end

    # Deletes an email template
    # @param template_id [Integer] The template ID
    # @return nil
    # @!macro api_errors
    def delete(template_id)
      client.delete("#{base_path}/#{template_id}")
    end

    private

    def build_email_template(options)
      EmailTemplate.new(options.slice(*EmailTemplate.members))
    end

    def base_path
      "/api/accounts/#{account_id}/email_templates"
    end

    def validate_options(options, supported_options = SUPPORTED_OPTIONS)
      invalid_options = options.keys - supported_options
      return unless invalid_options.any?

      raise ArgumentError, "invalid options are given: #{invalid_options}, supported_options: #{supported_options}"
    end
  end
end
