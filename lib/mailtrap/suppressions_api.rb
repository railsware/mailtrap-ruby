# frozen_string_literal: true

require_relative 'suppression'

module Mailtrap
  class SuppressionsAPI < BaseAPI
    # Lists all suppressions for the account
    # @param email [String] Email address to filter suppressions (optional)
    # @return [Array<Suppression>] Array of suppression objects
    # @!macro api_errors
    def list(email: nil)
      query_params = {}
      query_params[:email] = email if email

      response = client.get(base_path, query_params)
      response.map { |suppression| build_entity(suppression, Suppression) }
    end

    # Deletes a suppression
    # @param suppression_id [String] The suppression UUID
    # @return nil
    # @!macro api_errors
    def delete(suppression_id)
      client.delete("#{base_path}/#{suppression_id}")
    end

    private

    def base_path
      "/api/accounts/#{@account_id}/suppressions"
    end
  end
end
