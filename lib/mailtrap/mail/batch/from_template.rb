# frozen_string_literal: true

module Mailtrap
  module Mail
    module Batch
      # Batch email class for sending emails using templates.
      # Inherits all properties from Batch::Base and adds template-specific fields.
      # @!macro batch_email_base_properties
      # @!attribute [rw] template_uuid
      #   @return [String, nil] UUID of email template.
      # @!attribute [rw] template_variables
      #   @return [Hash] Optional template variables that will be used to generate actual subject, text and html from email template. # rubocop:disable Layout/LineLength
      class FromTemplate < Base
        attr_accessor :template_uuid, :template_variables

        # Initializes a new Mailtrap::Mail::Batch::FromTemplate object.
        #
        # @macro batch_email_base_initialize_params
        # @param template_uuid [String, nil] UUID of email template.
        # @param template_variables [Hash] Optional template variables for generating email content.
        def initialize( # rubocop:disable Metrics/ParameterLists
          from: nil,
          reply_to: nil,
          attachments: [],
          headers: {},
          custom_variables: {},
          template_uuid: nil,
          template_variables: {}
        )
          super(
            from:,
            reply_to:,
            attachments:,
            headers:,
            custom_variables:
          )
          @template_uuid = template_uuid
          @template_variables = template_variables
        end

        # Returns a hash representation of the template-based batch email suitable for JSON serialization.
        # @return [Hash] The template-based batch email as a hash.
        def as_json
          super.merge(
            {
              'template_uuid' => template_uuid,
              'template_variables' => template_variables
            }
          ).compact
        end
      end
    end
  end
end
