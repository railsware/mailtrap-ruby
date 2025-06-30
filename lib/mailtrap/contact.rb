# frozen_string_literal: true

module Mailtrap
  # Data Transfer Object for Contact
  # @see https://api-docs.mailtrap.io/docs/mailtrap-api-docs/220a54e31e5ca-contact
  # @attr_reader id [String] The contact ID
  # @attr_reader email [String] The contact's email address
  # @attr_reader fields [Hash] Object of fields with merge tags
  # @attr_reader list_ids [Array<Integer>] Array of list IDs
  # @attr_reader status [String] The contact status (subscribed/unsubscribed)
  # @attr_reader created_at [Integer] The creation timestamp
  # @attr_reader updated_at [Integer] The last update timestamp
  Contact = Struct.new(
    :id,
    :email,
    :fields,
    :list_ids,
    :status,
    :created_at,
    :updated_at,
    keyword_init: true
  ) do
    # @return [Hash] The contact attributes as a hash
    def to_h
      super.compact
    end
  end

  # Data Transfer Object for Contact Update Response
  # @see https://api-docs.mailtrap.io/docs/mailtrap-api-docs/16eab4fff9740-contact-update-response
  # @attr_reader action [String] The performed action (created/updated)
  # @attr_reader data [Contact, Hash] The contact data
  ContactUpdateResponse = Struct.new(:action, :data, keyword_init: true) do
    def initialize(*)
      super
      self.data = Contact.new(data) if data.is_a?(Hash)
    end

    # @return [Hash] The response attributes as a hash
    def to_h
      super.compact
    end
  end
end
