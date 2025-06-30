# frozen_string_literal: true

module Mailtrap
  # Data Transfer Object for Contact List
  # @see https://api-docs.mailtrap.io/docs/mailtrap-api-docs/6ec7a37234af2-contact-list
  # @attr_reader id [Integer] The contact list ID
  # @attr_reader name [String] The name of the contact list
  ContactList = Struct.new(:id, :name, keyword_init: true) do
    # @return [Hash] The contact list attributes as a hash
    def to_h
      super.compact
    end
  end
end
