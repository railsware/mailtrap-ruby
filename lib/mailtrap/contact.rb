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
    def initialize(options)
      @action = options[:action]
      super(options.except(:action))
    end

    # @return [Boolean] Whether the contact was newly created
    def newly_created?
      @action != 'updated'
    end

    # @return [Hash] The contact attributes as a hash
    def to_h
      super.compact
    end
  end
end
