# frozen_string_literal: true

require_relative 'contact_import'
require_relative 'contacts_import_request'

module Mailtrap
  class ContactImportsAPI
    include BaseAPI

    self.supported_options = %i[email fields list_ids_included list_ids_excluded]

    self.response_class = ContactImport

    # Retrieves a specific contact import
    # @param import_id [String] The contact import identifier
    # @return [ContactImport] Contact import object
    # @!macro api_errors
    def get(import_id)
      base_get(import_id)
    end

    # Create contacts import
    # @param contacts [Array<Hash>, ContactsImportRequest, #to_a] Any object that responds to #to_a and returns an array of contact hashes. # rubocop:disable Layout/LineLength
    #   Accepts Array<Hash>, ContactsImportRequest, or any other object implementing #to_a
    #   When using Array<Hash>, each contact object should have the following keys:
    #   - email [String] The contact's email address
    #   - fields [Hash] Object of fields in the format: field_merge_tag => String, Integer, Float, Boolean, or ISO-8601 date string (yyyy-mm-dd) # rubocop:disable Layout/LineLength
    #   - list_ids_included [Array<Integer>] List IDs to include the contact in
    #   - list_ids_excluded [Array<Integer>] List IDs to exclude the contact from
    # @return [ContactImport] Created contact list object
    # @!macro api_errors
    # @raise [ArgumentError] If invalid options are provided
    def create(contacts)
      contact_data = contacts.to_a
      contact_data.each do |contact|
        validate_options!(contact, supported_options)
      end
      response = client.post(base_path, contacts: contact_data)
      handle_response(response)
    end
    alias start create

    private

    def base_path
      "/api/accounts/#{account_id}/contacts/imports"
    end
  end
end
