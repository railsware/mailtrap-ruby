# frozen_string_literal: true

module Mailtrap
  class EmailTemplatesAPI
    attr_reader :client, :account_id

    # @param account_id [Integer] The account ID
    # @param client [Mailtrap::Client] The client instance
    def initialize(account_id, client = Client.new)
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
    # @param [String] name The template name
    # @param [String] subject The email subject
    # @param [String] category The template category
    # @param [String, nil] body_html The HTML content. Default: nil.
    # @param [String, nil] body_text The plain text content. Default: nil.
    # @return [EmailTemplate] Created template object
    # @!macro api_errors
    def create(name:, subject:, category:, body_html: nil, body_text: nil) # rubocop:disable Metrics/MethodLength
      response = client.post(base_path,
                             {
                               email_template: {
                                 name:,
                                 subject:,
                                 category:,
                                 body_html:,
                                 body_text:
                               }
                             })
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
    def update(template_id, **options)
      response = client.patch("#{base_path}/#{template_id}",
                              {
                                email_template: options.slice(:name, :subject, :category, :body_html, :body_text)
                              })
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
  end
end
