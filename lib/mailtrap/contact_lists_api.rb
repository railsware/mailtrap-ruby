# frozen_string_literal: true

require_relative 'contact_list'

module Mailtrap
  class ContactListsAPI
    include BaseAPI

    supported_options %i[name]

    response_class ContactList

    # Retrieves a specific contact list
    # @param list_id [Integer] The contact list identifier
    # @return [ContactList] Contact list object
    # @!macro api_errors
    def get(list_id)
      base_get(list_id)
    end

    # Creates a new contact list
    # @param [Hash] options The parameters to create
    # @option options [String] :name The contact list name
    # @return [ContactList] Created contact list object
    # @!macro api_errors
    # @raise [ArgumentError] If invalid options are provided
    def create(options)
      base_create(options)
    end

    # Updates an existing contact list
    # @param list_id [Integer] The contact list ID
    # @param [Hash] options The parameters to update
    # @option options [String] :name The contact list name
    # @return [ContactList] Updated contact list object
    # @!macro api_errors
    # @raise [ArgumentError] If invalid options are provided
    def update(list_id, options)
      base_update(list_id, options)
    end

    # Deletes a contact list
    # @param list_id [Integer] The contact list ID
    # @return nil
    # @!macro api_errors
    def delete(list_id)
      base_delete(list_id)
    end

    # Lists all contact lists for the account
    # @return [Array<ContactList>] Array of contact list objects
    # @!macro api_errors
    def list
      base_list
    end

    private

    def base_path
      "/api/accounts/#{account_id}/contacts/lists"
    end
  end
end
