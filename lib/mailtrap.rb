# frozen_string_literal: true

require_relative 'mailtrap/action_mailer' if defined? ActionMailer
require_relative 'mailtrap/mail'
require_relative 'mailtrap/errors'
require_relative 'mailtrap/version'
require_relative 'mailtrap/email_templates_api'

module Mailtrap
  # @!macro api_errors
  #   @raise [Mailtrap::Error] If the API request fails with a client or server error
  #   @raise [Mailtrap::AuthorizationError] If the API key is invalid
  #   @raise [Mailtrap::RejectionError] If the server refuses to process the request
  #   @raise [Mailtrap::RateLimitError] If too many requests are made
end
