# frozen_string_literal: true

module Mailtrap
  module Mail
    # @deprecated Use Mailtrap::Mail::Base
    class FromTemplate < Base
      def initialize( # rubocop:disable Metrics/ParameterLists
        from: nil,
        to: [],
        reply_to: nil,
        cc: [],
        bcc: [],
        attachments: [],
        headers: {},
        custom_variables: {},
        template_uuid: nil,
        template_variables: {}
      )
        super
      end

      # Converts this template-based Mail object to a Mailtrap::Mail::Batch::FromTemplate object for batch sending.
      #
      # @return [Mailtrap::Mail::Batch::FromTemplate] A new batch email object with the same properties as this template mail. # rubocop:disable Layout/LineLength
      def to_batch
        Mailtrap::Mail::Batch::FromTemplate.new(
          from:,
          reply_to:,
          attachments:,
          headers:,
          custom_variables:,
          template_uuid:,
          template_variables:
        )
      end
    end
  end
end
