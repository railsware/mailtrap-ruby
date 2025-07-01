# frozen_string_literal: true

require_relative 'contact_list'

module Mailtrap
  class ContactListsAPI < BaseAPI
    SUPPORTED_OPTIONS = %i[name].freeze
    private_constant :SUPPORTED_OPTIONS

    # Retrieves a specific contact list
    # @param list_id [Integer] The contact list identifier
    # @return [ContactList] Contact list object
    # @!macro api_errors
    def get(list_id)
      response = client.get("#{base_path}/#{list_id}")
      build_entity(response, ContactList)
    end

    # Creates a new contact list
    # @param [Hash] options The parameters to create
    # @option options [String] :name The contact list name
    # @return [ContactList] Created contact list object
    # @!macro api_errors
    # @raise [ArgumentError] If invalid options are provided
    def create(options)
      validate_options!(options, SUPPORTED_OPTIONS)

      response = client.post(base_path, options)
      build_entity(response, ContactList)
    end

    # Updates an existing contact list
    # @param list_id [Integer] The contact list ID
    # @param [Hash] options The parameters to update
    # @option options [String] :name The contact list name
    # @return [ContactList] Updated contact list object
    # @!macro api_errors
    # @raise [ArgumentError] If invalid options are provided
    def update(list_id, options)
      validate_options!(options, SUPPORTED_OPTIONS)

      response = client.patch(
        "#{base_path}/#{list_id}", options
      )
      build_entity(response, ContactList)
    end

    # Deletes a contact list
    # @param list_id [Integer] The contact list ID
    # @return nil
    # @!macro api_errors
    def delete(list_id)
      client.delete("#{base_path}/#{list_id}")
    end

    # Lists all contact lists for the account
    # @return [Array<ContactList>] Array of contact list objects
    # @!macro api_errors
    def list
      response = client.get(base_path)
      response.map { |list| build_entity(list, ContactList) }
    end

    private

    def base_path
      "/api/accounts/#{account_id}/contacts/lists"
    end
  end
end
