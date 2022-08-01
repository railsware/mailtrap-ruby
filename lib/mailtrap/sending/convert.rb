# frozen_string_literal: true

require 'base64'

module Mailtrap
  module Sending
    module Convert
      class << self
        def from_message(message) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          Mailtrap::Sending::Mail.new(
            from: prepare_address(message['from']&.address_list&.addresses&.first),
            to: prepare_addresses(message['to']&.address_list&.addresses),
            cc: prepare_addresses(message['cc']&.address_list&.addresses),
            bcc: prepare_addresses(message['bcc']&.address_list&.addresses),
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

        PROCESSED_HEADERS = %w[
          from
          to
          cc
          bcc
          subject
          category
          customvariables
          contenttype
        ].freeze

        def prepare_addresses(addresses)
          Array(addresses).map { |address| prepare_address(address) }
        end

        def prepare_headers(message)
          message
            .header_fields
            .reject { |header| PROCESSED_HEADERS.include?(header.name.downcase.delete('-')) }
            .to_h { |header| [header.name, header.value] }
            .compact
        end

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
              content_id: attachment.header[:content_id]&.field&.content_id
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
end
