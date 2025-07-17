# frozen_string_literal: true

RSpec.describe Mailtrap::ContactImportsAPI do
  let(:client) { described_class.new('1111111', Mailtrap::Client.new(api_key: 'correct-api-key')) }
  let(:base_url) { 'https://mailtrap.io/api/accounts/1111111' }

  describe '#get' do
    let(:import_id) { 'import-123' }
    let(:expected_response) do
      {
        'id' => 'import-123',
        'status' => 'finished',
        'created_contacts_count' => 10,
        'updated_contacts_count' => 2,
        'contacts_over_limit_count' => 0
      }
    end

    it 'returns a specific contact import' do
      stub_request(:get, "#{base_url}/contacts/imports/#{import_id}")
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.get(import_id)
      expect(response).to have_attributes(
        id: 'import-123',
        status: 'finished',
        created_contacts_count: 10,
        updated_contacts_count: 2,
        contacts_over_limit_count: 0
      )
    end

    it 'raises error when contact import not found' do
      stub_request(:get, "#{base_url}/contacts/imports/not-found")
        .to_return(
          status: 404,
          body: { 'error' => 'Not Found' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { client.get('not-found') }.to raise_error(Mailtrap::Error)
    end
  end

  describe '#create' do
    let(:contacts) do
      [
        {
          email: 'example@example.com',
          fields: {
            fname: 'John',
            age: 30,
            is_subscribed: true,
            birthday: '1990-05-15'
          },
          list_ids_included: [1, 2],
          list_ids_excluded: [3]
        }
      ]
    end
    let(:expected_response) do
      {
        'id' => 'import-456',
        'status' => 'created',
        'created_contacts_count' => 1,
        'updated_contacts_count' => 0,
        'contacts_over_limit_count' => 0
      }
    end

    it 'creates a new contact import with hash' do
      stub_request(:post, "#{base_url}/contacts/imports")
        .with(body: { contacts: }.to_json)
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.create(contacts)
      expect(response).to have_attributes(
        id: 'import-456',
        status: 'created',
        created_contacts_count: 1,
        updated_contacts_count: 0,
        contacts_over_limit_count: 0
      )
    end

    it 'raises error when invalid options are provided' do
      invalid_contacts = [contacts.first.merge(foo: 'bar')]
      expect { client.create(invalid_contacts) }.to raise_error(ArgumentError, /invalid options are given/)
    end

    it 'raises error when API returns an error' do
      stub_request(:post, "#{base_url}/contacts/imports")
        .with(body: { contacts: }.to_json)
        .to_return(
          status: 422,
          body: { 'errors' => { 'email' => ['is invalid'] } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { client.create(contacts) }.to raise_error(Mailtrap::Error)
    end
  end
end
