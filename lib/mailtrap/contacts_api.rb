# frozen_string_literal: true

require_relative 'contact'

module Mailtrap
  class ContactsAPI
    include BaseAPI

    self.supported_options = %i[email fields list_ids]
    self.response_class = Contact

    # Retrieves a specific contact
    # @param contact_id [String] The contact identifier, which can be either a UUID or an email address
    # @return [Contact] Contact object
    # @!macro api_errors
    def get(contact_id)
      base_get(contact_id)
    end

    # Creates a new contact
    # @param [Hash] options The parameters to create
    # @option options [String] :email The contact's email address
    # @option options [Hash] :fields The contact's fields
    # @option options [Array<Integer>] :list_ids The contact's list IDs
    # @return [Contact] Created contact object
    # @!macro api_errors
    # @raise [ArgumentError] If invalid options are provided
    def create(options)
      base_create(options)
    end

    # Deletes a contact
    # @param contact_id [String] The contact ID
    # @return nil
    # @!macro api_errors
    def delete(contact_id)
      base_delete(contact_id)
    end

    # Updates an existing contact or creates a new one if it doesn't exist
    # @param contact_id [String] The contact ID or email address
    # @param [Hash] options The parameters to update
    # @option options [String] :email The contact's email address
    # @option options [Hash] :fields The contact's fields
    # @option options [Boolean] :unsubscribed Whether to unsubscribe the contact
    # @return [Contact] Updated contact object
    # @!macro api_errors
    # @raise [ArgumentError] If invalid options are provided
    def upsert(contact_id, options)
      base_update(contact_id, options, %i[email fields unsubscribed])
    end

    # Adds a contact to specified lists
    # @param contact_id [String] The contact ID or email address
    # @param contact_list_ids [Array<Integer>] Array of list IDs to add the contact to
    # @return [Contact] Updated contact object
    # @!macro api_errors
    def add_to_lists(contact_id, contact_list_ids = [])
      update_lists(contact_id, list_ids_included: contact_list_ids)
    end

    # Removes a contact from specified lists
    # @param contact_id [String] The contact ID or email address
    # @param contact_list_ids [Array<Integer>] Array of list IDs to remove the contact from
    # @return [Contact] Updated contact object
    # @!macro api_errors
    def remove_from_lists(contact_id, contact_list_ids = [])
      update_lists(contact_id, list_ids_excluded: contact_list_ids)
    end

    private

    def update_lists(contact_id, options)
      base_update(contact_id, options, %i[list_ids_included list_ids_excluded])
    end

    def wrap_request(options)
      { contact: options }
    end

    def handle_response(response)
      response_class.new response[:data].slice(*response_class.members).merge(action: response[:action])
    end

    def base_path
      "/api/accounts/#{account_id}/contacts"
    end
  end
end
