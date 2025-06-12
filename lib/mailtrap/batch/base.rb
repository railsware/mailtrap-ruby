# frozen_string_literal: true

module Mailtrap
  module Batch
    class Base < Mailtrap::Mail::Base
      EXTRA_ALLOWED_KEYS = %i[
        template_uuid template_variables
      ].freeze

      attr_reader :extra_options

      def initialize(**params)
        mail_base_keys = instance_variables_from_mail_base
        base_params = params.slice(*mail_base_keys)

        validate_base!(base_params)

        @extra_options = params.slice(*EXTRA_ALLOWED_KEYS)

        unknown_keys = params.keys - base_params.keys - @extra_options.keys
        warn("[Mailtrap::Batch::Base] Ignored unknown keys: #{unknown_keys.join(", ")}") if unknown_keys.any?

        super(**base_params)
      end

      def as_json(*args)
        super.merge(extra_options.compact)
      end

      def to_json(*args)
        JSON.generate(as_json(*args))
      end

      private

      def validate_base!(params)
        from = params[:from]
        raise ArgumentError, "'from' must be a Hash" unless from.is_a?(Hash)

        Mailtrap::Validators::EmailValidator.validate!(from[:email], field_name: 'from[:email]')
      end

      def instance_variables_from_mail_base
        base_keys = Mailtrap::Mail::Base
                    .instance_methods(false)
                    .grep(/=$/)
                    .map { |m| m.to_s.chomp('=').to_sym }

        base_keys | [:attachments]
      end
    end
  end
end