# frozen_string_literal: true

module Mailtrap
  module BaseAPI
    attr_reader :account_id, :client

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def supported_options=(options)
        @supported_options = options
      end

      def supported_options
        @supported_options
      end

      def response_class=(response_class)
        @response_class = response_class
      end

      def response_class
        @response_class
      end
    end

    # @param account_id [Integer] The account ID
    # @param client [Mailtrap::Client] The client instance
    # @raise [ArgumentError] If account_id is nil
    def initialize(account_id = ENV.fetch('MAILTRAP_ACCOUNT_ID'), client = Mailtrap::Client.new)
      raise ArgumentError, 'account_id is required' if account_id.nil?

      @account_id = account_id
      @client = client
    end

    private

    def supported_options
      self.class.supported_options
    end

    def response_class
      self.class.response_class
    end

    def validate_options!(options, supported_options)
      invalid_options = options.keys - supported_options
      return if invalid_options.empty?

      raise ArgumentError, "invalid options are given: #{invalid_options}, supported_options: #{supported_options}"
    end

    def build_entity(options, response_class)
      response_class.new(options.slice(*response_class.members))
    end

    def base_get(id)
      response = client.get("#{base_path}/#{id}")
      handle_response(response)
    end

    def base_create(options, supported_options_override = supported_options)
      validate_options!(options, supported_options_override)
      response = client.post(base_path, wrap_request(options))
      handle_response(response)
    end

    def base_update(id, options, supported_options_override = supported_options)
      validate_options!(options, supported_options_override)
      response = client.patch("#{base_path}/#{id}", wrap_request(options))
      handle_response(response)
    end

    def base_delete(id)
      client.delete("#{base_path}/#{id}")
    end

    def base_list
      response = client.get(base_path)
      response.map { |item| handle_response(item) }
    end

    def handle_response(response)
      build_entity(response, response_class)
    end

    def wrap_request(options)
      options
    end

    def base_path
      raise NotImplementedError, 'base_path must be implemented in the including class'
    end
  end
end
