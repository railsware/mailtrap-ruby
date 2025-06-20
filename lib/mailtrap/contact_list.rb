# frozen_string_literal: true

module Mailtrap
  # Data Transfer Object for Contact List Create Request
  # @see https://api-docs.mailtrap.io/docs/mailtrap-api-docs/e3bba0bfa185e-create-contact-list
  # @attr_reader name [String] The name of the contact list (required)
  ContactListRequest = Struct.new(:name, keyword_init: true) do
    # @return [Hash] The contact list request attributes as a hash
    def to_h
      super.compact
    end
  end

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

  class ContactListsAPI
    include Mailtrap::API

    def initialize(account_id, client = Mailtrap::Client.new)
      @account_id = account_id
      @client = client
    end

    # Retrieves a specific contact list
    # @param list_id [Integer] The contact list identifier
    # @return [ContactList] Contact list object
    # @raise [Mailtrap::Error] If the API request fails with a client or server error
    # @raise [Mailtrap::AuthorizationError] If the API key is invalid
    # @raise [Mailtrap::RejectionError] If the server refuses to process the request
    # @raise [Mailtrap::RateLimitError] If too many requests are made
    def get(list_id)
      response = @client.get("#{base_path}/#{list_id}")
      build_entity(response, ContactList)
    end

    # Creates a new contact list
    # @param request [ContactListRequest, Hash] The contact list create request object or a hash
    # @return [ContactList] Created contact list object
    # @raise [Mailtrap::Error] If the API request fails with a client or server error
    # @raise [Mailtrap::AuthorizationError] If the API key is invalid
    # @raise [Mailtrap::RejectionError] If the server refuses to process the request
    # @raise [Mailtrap::RateLimitError] If too many requests are made
    def create(request)
      response = @client.post(base_path, prepare_request(request, ContactListRequest))
      build_entity(response, ContactList)
    end

    # Updates an existing contact list
    # @param list_id [Integer] The contact list ID
    # @param request [ContactListRequest, Hash] The contact list update request object or a hash
    # @return [ContactList] Updated contact list object
    # @raise [Mailtrap::Error] If the API request fails with a client or server error
    # @raise [Mailtrap::AuthorizationError] If the API key is invalid
    # @raise [Mailtrap::RejectionError] If the server refuses to process the request
    # @raise [Mailtrap::RateLimitError] If too many requests are made
    def update(list_id, request)
      response = @client.patch(
        "#{base_path}/#{list_id}", prepare_request(request, ContactListRequest)
      )
      build_entity(response, ContactList)
    end

    # Deletes a contact list
    # @param list_id [Integer] The contact list ID
    # @return nil
    # @raise [Mailtrap::Error] If the API request fails with a client or server error
    # @raise [Mailtrap::AuthorizationError] If the API key is invalid
    # @raise [Mailtrap::RejectionError] If the server refuses to process the request
    # @raise [Mailtrap::RateLimitError] If too many requests are made
    def delete(list_id)
      @client.delete("#{base_path}/#{list_id}")
    end

    # Lists all contact lists for the account
    # @return [Array<ContactList>] Array of contact list objects
    def list
      response = @client.get(base_path)
      response.map { |list| build_entity(list, ContactList) }
    end

    private

    def base_path
      "/api/accounts/#{@account_id}/contacts/lists"
    end
  end
end
