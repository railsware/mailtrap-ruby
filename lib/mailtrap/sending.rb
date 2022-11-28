# frozen_string_literal: true

require_relative 'sending/attachment'
require_relative 'sending/base'
require_relative 'sending/client'
require_relative 'sending/convert'
require_relative 'sending/mail'

module Mailtrap
  module Sending
    class AttachmentContentError < StandardError; end

    class Error < StandardError
      attr_reader :messages

      def initialize(messages)
        @messages = messages

        super(messages.join(', '))
      end
    end

    class AuthorizationError < Error; end
  end
end
