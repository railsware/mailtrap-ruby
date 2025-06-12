# frozen_string_literal: true

require_relative 'mailtrap/action_mailer' if defined? ActionMailer
require_relative 'mailtrap/validators/email_validator'
require_relative 'mailtrap/mail'
require_relative 'mailtrap/batch/base'
require_relative 'mailtrap/batch_sender'
require_relative 'mailtrap/errors'
require_relative 'mailtrap/version'

module Mailtrap; end
