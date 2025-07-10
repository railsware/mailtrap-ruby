# frozen_string_literal: true

require 'base64'

require_relative 'mail/base'
require_relative 'mail/from_template'
require_relative 'errors'

module Mailtrap
  module Mail # rubocop:disable Metrics/ModuleLength
    class << self
      # Builds a mail object that will be sent using a pre-defined email
      # template. The template content (subject, text, html, category) is
      # defined in the Mailtrap dashboard and referenced by the template_uuid.
      # Template variables can be passed to customize the template content.
      def from_template( # rubocop:disable Metrics/ParameterLists
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
        Mailtrap::Mail::Base.new(
          from:,
          to:,
          reply_to:,
          cc:,
          bcc:,
          attachments:,
          headers:,
          custom_variables:,
          template_uuid:,
          template_variables:
        )
      end

      # Builds a mail object with content including subject, text, html, and category.
      def from_content( # rubocop:disable Metrics/ParameterLists
        from: nil,
        to: [],
        reply_to: nil,
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
        Mailtrap::Mail::Base.new(
          from:,
          to:,
          reply_to:,
          cc:,
          bcc:,
          attachments:,
          headers:,
          custom_variables:,
          subject:,
          text:,
          html:,
          category:
        )
      end

      # Builds a mail object from Mail::Message
      # @param message [Mail::Message]
      # @return [Mailtrap::Mail::Base]
      def from_message(message) # rubocop:disable Metrics/AbcSize
        Mailtrap::Mail::Base.new(
          from: prepare_addresses(address_list(message['from'])&.addresses).first,
          to: prepare_addresses(address_list(message['to'])&.addresses),
          cc: prepare_addresses(address_list(message['cc'])&.addresses),
          bcc: prepare_addresses(address_list(message['bcc'])&.addresses),
          subject: message.subject,
          text: prepare_text_part(message),
          html: prepare_html_part(message),
          headers: prepare_headers(message),
          attachments: prepare_attachments(message.attachments),
          category: message['category']&.unparsed_value,
          custom_variables: message['custom_variables']&.unparsed_value
        )
      end

      private

      SPECIAL_HEADERS = %w[
        from
        to
        cc
        bcc
        subject
        category
        customvariables
        contenttype
      ].freeze

      # ActionMailer adds these headers by calling `Mail::Message#encoded`,
      # as if the message is to be delivered via SMTP.
      # Since the message will actually be generated on the Mailtrap side from its components,
      # the headers are redundant and potentially conflicting, so we remove them.
      ACTIONMAILER_ADDED_HEADERS = %w[
        contenttransferencoding
        date
        messageid
        mimeversion
      ].freeze

      HEADERS_TO_REMOVE = (SPECIAL_HEADERS + ACTIONMAILER_ADDED_HEADERS).freeze

      # @param header [Mail::Field, nil]
      # @return [Mail::AddressList, nil]
      def address_list(header)
        return nil unless header

        unless header.errors.empty?
          raise Mailtrap::Error, ["failed to parse '#{header.name}': '#{header.unparsed_value}'"]
        end

        header.respond_to?(:element) ? header.element : header.address_list
      end

      # @param addresses [Array<Mail::Address>, nil]
      def prepare_addresses(addresses)
        Array(addresses).map { |address| prepare_address(address) }
      end

      def prepare_headers(message)
        message
          .header_fields
          .reject { |header| HEADERS_TO_REMOVE.include?(header.name.downcase.delete('-')) }
          .to_h { |header| [header.name, header.value] }
          .compact
      end

      # @param address [Mail::Address]
      def prepare_address(address)
        {
          email: address.address,
          name: address.display_name
        }.compact
      end

      def prepare_attachments(attachments_list = [])
        attachments_list.map do |attachment|
          {
            content: Base64.strict_encode64(attachment.body.decoded),
            type: attachment.mime_type,
            filename: attachment.filename,
            disposition: attachment.header[:content_disposition]&.disposition_type,
            content_id: attachment&.cid
          }.compact
        end
      end

      def prepare_html_part(message)
        return message.body.decoded if message.mime_type == 'text/html'

        message.html_part&.decoded
      end

      def prepare_text_part(message)
        return message.body.decoded if message.mime_type == 'text/plain' || message.mime_type.nil?

        message.text_part&.decoded
      end
    end
  end
end
