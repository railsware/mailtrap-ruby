# frozen_string_literal: true

module Mailtrap
  module Mail
    class FromTemplate < Base
      attr_accessor :template_uuid, :template_variables

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
        super(
          from:,
          to:,
          reply_to:,
          cc:,
          bcc:,
          attachments:,
          headers:,
          custom_variables:
        )
        @template_uuid = template_uuid
        @template_variables = template_variables
      end

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
