# frozen_string_literal: true

module Mailtrap
  # Data Transfer Object for Project
  # @see https://api-docs.mailtrap.io/docs/mailtrap-api-docs/ee252e413d78a-create-project
  # @attr_reader id [String] The contact ID
  # @attr_reader name [String] The project name
  # @attr_reader share_links [Array] Array of links
  # @attr_reader inboxes [Array] Array of inboxes
  # @attr_reader permissions [Hash] List of permissions
  Project = Struct.new(
    :id,
    :name,
    :share_links,
    :inboxes,
    :permissions,
    keyword_init: true
  ) do
    def initialize(options)
      @action = options.delete(:action)
      super
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
