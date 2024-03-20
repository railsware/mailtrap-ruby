# frozen_string_literal: true

require_relative 'attachment'
require_relative 'client'

module Mailtrap
  class AttachmentContentError < StandardError; end

  class Error < StandardError
    attr_reader :messages

    def initialize(messages)
      @messages = messages

      super(messages.join(', '))
    end
  end

  # AuthorizationError is raised when invalid token is used.
  class AuthorizationError < Error; end

  # MailSizeError is raised when mail is too large.
  class MailSizeError < Error; end

  # RateLimitError is raised when client performing too many requests.
  class RateLimitError < Error; end

  # RejectionError is raised when server refuses to process the request. Use
  # error message to debug the problem.
  #
  # *Some* possible reasons:
  #   * Account is banned
  #   * Domain is not verified
  class RejectionError < Error; end
end
