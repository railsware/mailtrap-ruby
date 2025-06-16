# frozen_string_literal: true

require_relative 'mailtrap/action_mailer' if defined? ActionMailer
require_relative 'mailtrap/mail'
require_relative 'mailtrap/errors'
require_relative 'mailtrap/version'
require_relative 'mailtrap/template'

module Mailtrap; end
