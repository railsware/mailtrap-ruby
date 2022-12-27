# frozen_string_literal: true

module Mailtrap
  module Mail
    class FromTemplate < Base
      attr_accessor :template_uuid, :template_variables

      def initialize( # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
        from: nil,
        to: [],
        cc: [],
        bcc: [],
        attachments: [],
        headers: {},
        custom_variables: {},
        template_uuid: nil,
        template_variables: {}
      )
        super(
          from: from,
          to: to,
          cc: cc,
          bcc: bcc,
          attachments: attachments,
          headers: headers,
          custom_variables: custom_variables
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
