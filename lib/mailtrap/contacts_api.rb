# frozen_string_literal: true

require_relative 'contact'
require 'ostruct'

module Mailtrap
  class ContactsAPI < BaseAPI
    CREATE_SUPPORTED_OPTIONS = %i[email fields list_ids].freeze
    UPDATE_SUPPORTED_OPTIONS = %i[email fields list_ids_included list_ids_excluded unsubscribed].freeze
    private_constant :CREATE_SUPPORTED_OPTIONS, :UPDATE_SUPPORTED_OPTIONS

    # Retrieves a specific contact
    # @param contact_id [String] The contact identifier, which can be either a UUID or an email address
    # @return [Contact] Contact object
    # @!macro api_errors
    def get(contact_id)
      response = client.get("#{base_path}/#{contact_id}")
      build_entity(response[:data], Contact)
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
      validate_options!(options, CREATE_SUPPORTED_OPTIONS)

      response = client.post(base_path, { contact: options })
      build_entity(response[:data], Contact)
    end

    # Updates an existing contact
    # @param contact_id [String] The contact ID or email address
    # @param [Hash] options The parameters to update
    # @option options [String] :email The contact's email address
    # @option options [Hash] :fields The contact's fields
    # @option options [Array<Integer>] :list_ids_included The contact's list IDs to include
    # @option options [Array<Integer>] :list_ids_excluded The contact's list IDs to exclude
    # @option options [Boolean] :unsubscribed Whether to unsubscribe the contact
    # @return [ContactUpdateResponse] Updated contact object
    # @!macro api_errors
    # @raise [ArgumentError] If invalid options are provided
    def update(contact_id, options)
      validate_options!(options, UPDATE_SUPPORTED_OPTIONS)

      response = client.patch(
        "#{base_path}/#{contact_id}",
        { contact: options }
      )
      build_entity(response, ContactUpdateResponse)
    end

    # Deletes a contact
    # @param contact_id [String] The contact ID
    # @return nil
    # @!macro api_errors
    def delete(contact_id)
      client.delete("#{base_path}/#{contact_id}")
    end

    private

    def base_path
      "/api/accounts/#{account_id}/contacts"
    end
  end
end
