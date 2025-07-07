# frozen_string_literal: true

module Mailtrap
  # Data Transfer Object for Contact Field
  # @see https://api-docs.mailtrap.io/docs/mailtrap-api-docs/33efe96c91dcc-get-all-contact-fields
  # @attr_reader id [Integer] The contact field ID
  # @attr_reader name [String] The name of the contact field (max 80 characters)
  # @attr_reader data_type [String] The data type of the field
  #   Allowed values: text, integer, float, boolean, date
  # @attr_reader merge_tag [String] Personalize your campaigns by adding a merge tag.
  #   This field will be replaced with unique contact details for each recipient (max 80 characters)
  ContactField = Struct.new(:id, :name, :data_type, :merge_tag, keyword_init: true) do
    # @return [Hash] The contact field attributes as a hash
    def to_h
      super.compact
    end
  end
end
