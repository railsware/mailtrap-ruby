# frozen_string_literal: true

RSpec.describe Mailtrap::ContactListsAPI do
  let(:client) { described_class.new('1111111', Mailtrap::Client.new(api_key: 'correct-api-key')) }
  let(:base_url) { 'https://mailtrap.io/api/accounts/1111111' }

  describe '#list' do
    let(:expected_response) do
      [
        { 'id' => 1, 'name' => 'List 1' },
        { 'id' => 2, 'name' => 'List 2' }
      ]
    end

    it 'returns all contact lists' do
      stub_request(:get, "#{base_url}/contacts/lists")
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.list
      expect(response).to be_a(Array)
      expect(response.length).to eq(2)
      expect(response.first).to have_attributes(id: 1, name: 'List 1')
    end
  end

  describe '#get' do
    let(:contact_list_id) { 1 }
    let(:expected_response) do
      { 'id' => 1, 'name' => 'List 1' }
    end

    it 'returns a specific contact list' do
      stub_request(:get, "#{base_url}/contacts/lists/#{contact_list_id}")
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.get(contact_list_id)
      expect(response).to have_attributes(id: 1, name: 'List 1')
    end

    it 'raises error when contact list not found' do
      stub_request(:get, "#{base_url}/contacts/lists/999")
        .to_return(
          status: 404,
          body: { 'error' => 'Not Found' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { client.get(999) }.to raise_error(Mailtrap::Error)
    end
  end

  describe '#create' do
    let(:contact_list_name) { 'List 1' }
    let(:expected_response) do
      { 'id' => 1, 'name' => contact_list_name }
    end

    it 'creates a new contact list' do
      stub_request(:post, "#{base_url}/contacts/lists")
        .with(
          body: { name: contact_list_name }.to_json
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.create(name: contact_list_name)
      expect(response).to have_attributes(id: 1, name: contact_list_name)
    end

    it 'raises error when rate limit exceeded' do
      stub_request(:post, "#{base_url}/contacts/lists")
        .with(
          body: { name: contact_list_name }.to_json
        )
        .to_return(
          status: 429,
          body: { 'errors' => 'Rate limit exceeded' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { client.create(name: contact_list_name) }.to raise_error(Mailtrap::Error)
    end
  end

  describe '#update' do
    let(:contact_list_id) { 2 }
    let(:new_name) { 'List 2' }
    let(:expected_response) do
      { 'id' => 2, 'name' => new_name }
    end

    it 'updates a contact list' do
      stub_request(:patch, "#{base_url}/contacts/lists/#{contact_list_id}")
        .with(
          body: { name: new_name }.to_json
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.update(contact_list_id, name: new_name)
      expect(response).to have_attributes(id: 2, name: new_name)
    end

    it 'raises error when contact list not found' do
      stub_request(:patch, "#{base_url}/contacts/lists/999")
        .with(
          body: { name: new_name }.to_json
        )
        .to_return(
          status: 404,
          body: { 'error' => 'Not Found' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { client.update(999, name: new_name) }.to raise_error(Mailtrap::Error)
    end

    it 'raises error when validation fails' do
      stub_request(:patch, "#{base_url}/contacts/lists/#{contact_list_id}")
        .with(
          body: { name: '' }.to_json
        )
        .to_return(
          status: 422,
          body: { 'errors' => { 'name' => ['cannot be blank'] } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { client.update(contact_list_id, name: '') }.to raise_error(Mailtrap::Error)
    end
  end

  describe '#delete' do
    let(:contact_list_id) { 1 }

    it 'deletes a contact list' do
      stub_request(:delete, "#{base_url}/contacts/lists/#{contact_list_id}")
        .to_return(status: 204)

      response = client.delete(contact_list_id)
      expect(response).to be true
    end

    it 'raises error when contact list not found' do
      stub_request(:delete, "#{base_url}/contacts/lists/999")
        .to_return(
          status: 404,
          body: { 'error' => 'Not Found' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { client.delete(999) }.to raise_error(Mailtrap::Error)
    end

    it 'raises error when unauthorized' do
      stub_request(:delete, "#{base_url}/contacts/lists/#{contact_list_id}")
        .to_return(
          status: 401,
          body: { 'error' => 'Unauthorized' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { client.delete(contact_list_id) }.to raise_error(Mailtrap::AuthorizationError)
    end
  end
end
