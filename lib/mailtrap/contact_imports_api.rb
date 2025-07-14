# frozen_string_literal: true

require_relative 'contact_import'

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
    # @param contacts [Array<Hash>] Array of contact objects to import
    #   Each contact object should have the following keys:
    #   - email [String] The contact's email address
    #   - fields [Hash] Object of fields in the format: field_merge_tag => String, Integer, Float, Boolean, or ISO-8601 date string (yyyy-mm-dd) # rubocop:disable Layout/LineLength
    #   - list_ids_included [Array<Integer>] List IDs to include the contact in
    #   - list_ids_excluded [Array<Integer>] List IDs to exclude the contact from
    # @return [ContactImport] Created contact list object
    # @!macro api_errors
    # @raise [ArgumentError] If invalid options are provided
    def create(contacts)
      contacts.each do |contact|
        validate_options!(contact, supported_options)
      end
      response = client.post(base_path, contacts:)
      handle_response(response)
    end

    private

    def base_path
      "/api/accounts/#{account_id}/contacts/imports"
    end
  end
end
