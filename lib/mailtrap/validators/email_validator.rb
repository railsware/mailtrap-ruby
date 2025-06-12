# frozen_string_literal: true

module Mailtrap
  module Validators
    module EmailValidator
      module_function

      def valid?(email)
        email.to_s.match?(/@/)
      end

      def validate!(email, field_name: 'email')
        return if valid?(email)

        raise ArgumentError, "Invalid #{field_name}"
      end
    end
  end
end