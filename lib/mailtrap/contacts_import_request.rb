# frozen_string_literal: true

module Mailtrap
  # A builder class for creating contact import requests
  # Allows you to build a collection of contacts with their associated fields and list memberships
  class ContactsImportRequest
    def initialize
      @data = {}
    end

    # Creates or updates a contact with the provided email and fields
    # @param email [String] The contact's email address
    # @param fields [Hash] Contact fields in the format: field_merge_tag => String, Integer, Float, Boolean, or ISO-8601 date string (yyyy-mm-dd) # rubocop:disable Layout/LineLength
    # @return [ContactsImportRequest] Returns self for method chaining
    def upsert(email:, fields: {})
      unless @data[email]
        @data[email] = { email:, fields:, list_ids_included: [], list_ids_excluded: [] }
        return self
      end

      @data[email][:fields].merge!(fields)

      self
    end

    # Adds a contact to the specified lists
    # @param email [String] The contact's email address
    # @param list_ids [Array<Integer>] Array of list IDs to add the contact to
    # @return [ContactsImportRequest] Returns self for method chaining
    def add_to_lists(email:, list_ids:)
      unless @data[email]
        @data[email] = { email:, fields: {}, list_ids_included: list_ids, list_ids_excluded: [] }
        return self
      end

      @data[email][:list_ids_included] |= list_ids

      self
    end

    # Removes a contact from the specified lists
    # @param email [String] The contact's email address
    # @param list_ids [Array<Integer>] Array of list IDs to remove the contact from
    # @return [ContactsImportRequest] Returns self for method chaining
    def remove_from_lists(email:, list_ids:)
      unless @data[email]
        @data[email] = { email:, fields: {}, list_ids_included: [], list_ids_excluded: list_ids }
        return self
      end

      @data[email][:list_ids_excluded] |= list_ids

      self
    end

    # Converts the import request to a JSON-serializable array
    # @return [Array<Hash>] Array of contact objects ready for import
    def as_json
      @data.values
    end
    alias to_a as_json
  end
end
