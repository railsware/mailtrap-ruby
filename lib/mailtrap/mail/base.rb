# frozen_string_literal: true

require 'json'

module Mailtrap
  module Mail
    class Base
      attr_accessor :from, :to, :cc, :bcc, :headers, :custom_variables, :subject, :text, :html, :category
      attr_reader :attachments

      def initialize( # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
        from: nil,
        to: [],
        cc: [],
        bcc: [],
        subject: nil,
        text: nil,
        html: nil,
        attachments: [],
        headers: {},
        custom_variables: {},
        category: nil
      )
        @from = from
        @to = to
        @cc = cc
        @bcc = bcc
        @subject = subject
        @text = text
        @html = html
        self.attachments = attachments
        @headers = headers
        @custom_variables = custom_variables
        @category = category
      end

      def as_json # rubocop:disable Metrics/MethodLength
        {
          'from' => from,
          'to' => to,
          'cc' => cc,
          'bcc' => bcc,
          'subject' => subject,
          'text' => text,
          'html' => html,
          'attachments' => attachments.map(&:as_json),
          # TODO: update headers and custom_variables with as_json method
          'headers' => headers,
          'custom_variables' => custom_variables,
          'category' => category
        }.compact
      end

      def to_json(*args)
        JSON.generate(
          as_json,
          *args
        )
      end

      def attachments=(attachments)
        @attachments = attachments.map { |attachment| Mailtrap::Attachment.new(**attachment) }
      end

      def add_attachment(content:, filename:, type: nil, disposition: nil, content_id: nil)
        attachment = Mailtrap::Attachment.new(
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
