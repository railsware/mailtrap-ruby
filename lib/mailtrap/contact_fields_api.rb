# frozen_string_literal: true

require_relative 'base_api'
require_relative 'contact_field'

module Mailtrap
  class ContactFieldsAPI
    include BaseAPI

    self.supported_options = %i[name data_type merge_tag]

    self.response_class = ContactField

    # Retrieves a specific contact field
    # @param field_id [Integer] The contact field identifier
    # @return [ContactField] Contact field object
    # @!macro api_errors
    def get(field_id)
      base_get(field_id)
    end

    # Creates a new contact field
    # @param [Hash] options The parameters to create
    # @option options [String] :name The contact field name
    # @option options [String] :data_type The data type of the field
    # @option options [String] :merge_tag The merge tag of the field
    # @return [ContactField] Created contact field object
    # @!macro api_errors
    # @raise [ArgumentError] If invalid options are provided
    def create(options)
      base_create(options)
    end

    # Updates an existing contact field
    # @param field_id [Integer] The contact field ID
    # @param [Hash] options The parameters to update
    # @option options [String] :name The contact field name
    # @option options [String] :merge_tag The merge tag of the field
    # @return [ContactField] Updated contact field object
    # @!macro api_errors
    # @raise [ArgumentError] If invalid options are provided
    def update(field_id, options)
      base_update(field_id, options, %i[name merge_tag])
    end

    # Deletes a contact field
    # @param field_id [Integer] The contact field ID
    # @return nil
    # @!macro api_errors
    def delete(field_id)
      base_delete(field_id)
    end

    # Lists all contact fields for the account
    # @return [Array<ContactField>] Array of contact field objects
    # @!macro api_errors
    def list
      base_list
    end

    private

    def base_path
      "/api/accounts/#{account_id}/contacts/fields"
    end
  end
end
