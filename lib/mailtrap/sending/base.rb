# frozen_string_literal: true

require 'json'

module Mailtrap
  module Sending
    class Base
      attr_accessor :from, :to, :cc, :bcc, :headers, :custom_variables
      attr_reader :attachments

      def initialize( # rubocop:disable Metrics/ParameterLists
        from: nil,
        to: [],
        cc: [],
        bcc: [],
        attachments: [],
        headers: {},
        custom_variables: {}
      )
        @from = from
        @to = to
        @cc = cc
        @bcc = bcc
        self.attachments = attachments
        @headers = headers
        @custom_variables = custom_variables
      end

      def as_json
        {
          'to' => to,
          'from' => from,
          'cc' => cc,
          'bcc' => bcc,
          'attachments' => attachments.map(&:as_json),
          # TODO: update headers and custom_variables with as_json method
          'headers' => headers,
          'custom_variables' => custom_variables
        }.compact
      end

      def to_json(*args)
        JSON.generate(
          as_json,
          *args
        )
      end

      def attachments=(attachments)
        @attachments = attachments.map { |attachment| Mailtrap::Sending::Attachment.new(**attachment) }
      end

      def add_attachment(content:, filename:, type: nil, disposition: nil, content_id: nil)
        attachment = Mailtrap::Sending::Attachment.new(
          content: content,
          filename: filename,
          type: type,
          disposition: disposition,
          content_id: content_id
        )
        attachments << attachment

        attachment
      end
    end
  end
end
