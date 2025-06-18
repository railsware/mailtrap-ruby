# frozen_string_literal: true

module Mailtrap
  class BaseAPI
    attr_reader :account_id, :client

    # @param account_id [Integer] The account ID
    # @param client [Mailtrap::Client] The client instance
    # @raise [ArgumentError] If account_id is nil
    def initialize(account_id = ENV.fetch('MAILTRAP_ACCOUNT_ID'), client = Mailtrap::Client.new)
      raise ArgumentError, 'account_id is required' if account_id.nil?

      @account_id = account_id
      @client = client
    end

    private

    def validate_options!(options, supported_options)
      invalid_options = options.keys - supported_options
      return if invalid_options.empty?

      raise ArgumentError, "invalid options are given: #{invalid_options}, supported_options: #{supported_options}"
    end

    def build_entity(options, response_class)
      response_class.new(options.slice(*response_class.members))
    end
  end
end
