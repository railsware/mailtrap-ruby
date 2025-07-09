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
    end
  end
end
