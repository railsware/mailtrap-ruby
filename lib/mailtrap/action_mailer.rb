# frozen_string_literal: true

require_relative 'action_mailer/delivery_method'
require_relative 'action_mailer/railtie' if defined? Rails

module Mailtrap
  module ActionMailer; end
end
