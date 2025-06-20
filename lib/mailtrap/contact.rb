# frozen_string_literal: true

module Mailtrap
  # Data Transfer Object for Contact Create Request
  # @see https://api-docs.mailtrap.io/docs/mailtrap-api-docs/284bcc8fd846f-contact-create-request
  # @attr_reader email [String] The contact's email address (required)
  # @attr_reader fields [Hash] Object of fields with merge tags
  # @attr_reader list_ids [Array<Integer>] Array of list IDs
  ContactCreateRequest = Struct.new(:email, :fields, :list_ids, keyword_init: true) do
    # @return [Hash] The contact request attributes as a hash
    def to_h
      super.compact
    end
  end

  # Data Transfer Object for Contact Update Request
  # @see https://api-docs.mailtrap.io/docs/mailtrap-api-docs/d3efb09dbeda8-contact-update-request
  # @attr_reader email [String] The contact's email address (required)
  # @attr_reader fields [Hash] Object of fields with merge tags
  # @attr_reader list_ids_included [Array<Integer>] Array of list IDs to include
  # @attr_reader list_ids_excluded [Array<Integer>] Array of list IDs to exclude
  # @attr_reader unsubscribed [Boolean] Whether to unsubscribe the contact
  ContactUpdateRequest = Struct.new(:email, :fields, :list_ids_included, :list_ids_excluded, :unsubscribed,
                                    keyword_init: true) do
    # @return [Hash] The contact request attributes as a hash
    def to_h
      super.compact
    end
  end

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
  # @attr_reader data [Contact] The contact data
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

  class ContactsAPI
    include Mailtrap::API

    def initialize(account_id, client = Mailtrap::Client.new)
      @account_id = account_id
      @client = client
    end

    # Retrieves a specific contact
    # @param contact_id [String] The contact identifier, which can be either a UUID or an email address
    # @return [Contact] Contact object
    # @raise [Mailtrap::Error] If the API request fails with a client or server error
    # @raise [Mailtrap::AuthorizationError] If the API key is invalid
    # @raise [Mailtrap::RejectionError] If the server refuses to process the request
    # @raise [Mailtrap::RateLimitError] If too many requests are made
    def get(contact_id)
      response = @client.get("#{base_path}/#{contact_id}")
      build_entity(response[:data], Contact)
    end

    # Creates a new contact
    # @param request [ContactCreateRequest, Hash] The contact create request object or a hash with the same attributes
    # @return [Contact] Created contact object
    # @raise [Mailtrap::Error] If the API request fails with a client or server error
    # @raise [Mailtrap::AuthorizationError] If the API key is invalid
    # @raise [Mailtrap::RejectionError] If the server refuses to process the request
    # @raise [Mailtrap::RateLimitError] If too many requests are made
    def create(request)
      response = @client.post(base_path, { contact: prepare_request(request, ContactCreateRequest) })
      build_entity(response[:data], Contact)
    end

    # Updates an existing contact
    # @param contact_id [String] The contact ID
    # @param request [ContactUpdateRequest, Hash] The contact update request object or a hash with the same attributes
    # @return [ContactUpdateResponse] Response containing the action performed and contact data
    # @raise [Mailtrap::Error] If the API request fails with a client or server error
    # @raise [Mailtrap::AuthorizationError] If the API key is invalid
    # @raise [Mailtrap::RejectionError] If the server refuses to process the request
    # @raise [Mailtrap::RateLimitError] If too many requests are made
    def update(contact_id, request)
      response = @client.patch(
        "#{base_path}/#{contact_id}",
        { contact: prepare_request(request, ContactUpdateRequest) }
      )
      build_entity(response, ContactUpdateResponse)
    end

    # Deletes a contact
    # @param contact_id [String] The contact ID
    # @return nil
    # @raise [Mailtrap::Error] If the API request fails with a client or server error
    # @raise [Mailtrap::AuthorizationError] If the API key is invalid
    # @raise [Mailtrap::RejectionError] If the server refuses to process the request
    # @raise [Mailtrap::RateLimitError] If too many requests are made
    def delete(contact_id)
      @client.delete("#{base_path}/#{contact_id}")
    end

    private

    def base_path
      "/api/accounts/#{@account_id}/contacts"
    end
  end
end
