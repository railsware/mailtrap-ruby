# frozen_string_literal: true

module Mailtrap
  # Data Transfer Object for Contact Import
  # @attr_reader id [String] The contact import ID
  # @attr_reader status [String] The status of the import (created, started, finished, failed)
  # @attr_reader created_contacts_count [Integer, nil] Number of contacts created in this import
  # @attr_reader updated_contacts_count [Integer, nil] Number of contacts updated in this import
  # @attr_reader contacts_over_limit_count [Integer, nil] Number of contacts over the allowed limit
  ContactImport = Struct.new(
    :id,
    :status,
    :created_contacts_count,
    :updated_contacts_count,
    :contacts_over_limit_count,
    keyword_init: true
  ) do
    # @return [Hash] The contact attributes as a hash
    def to_h
      super.compact
    end
  end
end
