# frozen_string_literal: true

require 'json'

module Mailtrap
  module Mail
    module Batch
      # General properties of all emails in the batch. Each of them can be overridden in requests for individual emails.
      #
      # @!macro [new] batch_email_base_properties
      #   @!attribute [rw] from
      #     @return [String, nil] The sender email address.
      #   @!attribute [rw] reply_to
      #     @return [String, nil] The reply-to email address.
      #   @!attribute [rw] headers
      #     @return [Hash] The custom headers for the email.
      #   @!attribute [rw] custom_variables
      #     @return [Hash] The custom variables for the email.
      # @!macro [new] batch_email_base_initialize_params
      #   @param from [String, nil] The sender email address.
      #   @param reply_to [String, nil] The reply-to email address.
      #   @param attachments [Array<Hash>] The attachments for the email.
      #   @param headers [Hash] The custom headers for the email.
      #   @param custom_variables [Hash] The custom variables for the email.
      class Base < Mailtrap::Mail::Base
        # @!macro batch_email_base_properties
        # @!attribute [rw] text
        #   @return [String, nil] The plain text body of the email.
        # @!attribute [rw] html
        #   @return [String, nil] The HTML body of the email.
        # @!attribute [rw] category
        #   @return [String, nil] The category of the email.
        # @!attribute [r] attachments
        #   @return [Array<Mailtrap::Attachment>] The attachments for the email.
        # @!attribute [rw] subject
        #   @return [String, nil] The subject of the email.
        attr_accessor :from, :reply_to, :headers, :custom_variables, :subject, :text, :html, :category
        attr_reader :attachments

        # Initializes a new Mailtrap::Mail::Batch::Base object.
        #
        # @macro batch_email_base_initialize_params
        # @param subject [String, nil] The subject of the email.
        # @param text [String, nil] The plain text body of the email.
        # @param html [String, nil] The HTML body of the email.
        # @param category [String, nil] The category of the email.
        def initialize( # rubocop:disable Metrics/ParameterLists,Lint/MissingSuper
          from: nil,
          reply_to: nil,
          subject: nil,
          text: nil,
          html: nil,
          attachments: [],
          headers: {},
          custom_variables: {},
          category: nil
        )
          @from = from
          @reply_to = reply_to
          @subject = subject
          @text = text
          @html = html
          self.attachments = attachments
          @headers = headers
          @custom_variables = custom_variables
          @category = category
        end

        # Returns a hash representation of the batch email suitable for JSON serialization'.
        # @return [Hash] The batch email as a hash.
        def as_json
          super.except('to', 'cc', 'bcc')
        end
      end
    end
  end
end
