# frozen_string_literal: true

module Mailtrap
  module Sending
    class Mail < Base
      attr_accessor :subject, :text, :html, :category

      def initialize( # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
        from: nil,
        to: [],
        cc: [],
        bcc: [],
        attachments: [],
        headers: {},
        custom_variables: {},
        subject: nil,
        text: nil,
        html: nil,
        category: nil
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
        @subject = subject
        @text = text
        @html = html
        @category = category
      end

      def as_json
        super.merge(
          {
            'subject' => subject,
            'html' => html,
            'text' => text,
            'category' => category
          }
        ).compact
      end
    end
  end
end
