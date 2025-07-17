# frozen_string_literal: true

RSpec.describe Mailtrap::ContactFieldsAPI do
  let(:client) { described_class.new('1111111', Mailtrap::Client.new(api_key: 'correct-api-key')) }
  let(:base_url) { 'https://mailtrap.io/api/accounts/1111111' }

  describe '#list' do
    let(:expected_response) do
      [
        { 'id' => 1, 'name' => 'First Name', 'data_type' => 'text', 'merge_tag' => 'first_name' },
        { 'id' => 2, 'name' => 'Age', 'data_type' => 'integer', 'merge_tag' => 'age' }
      ]
    end

    it 'returns all contact fields' do
      stub_request(:get, "#{base_url}/contacts/fields")
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.list
      expect(response).to be_a(Array)
      expect(response.length).to eq(2)
      expect(response.first).to have_attributes(id: 1, name: 'First Name', data_type: 'text', merge_tag: 'first_name')
    end
  end

  describe '#get' do
    let(:contact_field_id) { 1 }
    let(:expected_response) do
      { 'id' => 1, 'name' => 'First Name', 'data_type' => 'text', 'merge_tag' => 'first_name' }
    end

    it 'returns a specific contact field' do
      stub_request(:get, "#{base_url}/contacts/fields/#{contact_field_id}")
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.get(contact_field_id)
      expect(response).to have_attributes(id: 1, name: 'First Name', data_type: 'text', merge_tag: 'first_name')
    end

    it 'raises error when contact field not found' do
      stub_request(:get, "#{base_url}/contacts/fields/999")
        .to_return(
          status: 404,
          body: { 'error' => 'Not Found' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { client.get(999) }.to raise_error(Mailtrap::Error)
    end
  end

  describe '#create' do
    let(:contact_field_data) do
      {
        name: 'Last Name',
        data_type: 'text',
        merge_tag: 'last_name'
      }
    end
    let(:expected_response) do
      { 'id' => 3, 'name' => 'Last Name', 'data_type' => 'text', 'merge_tag' => 'last_name' }
    end

    it 'creates a new contact field' do
      stub_request(:post, "#{base_url}/contacts/fields")
        .with(
          body: contact_field_data.to_json
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.create(contact_field_data)
      expect(response).to have_attributes(id: 3, name: 'Last Name', data_type: 'text', merge_tag: 'last_name')
    end

    it 'raises error when rate limit exceeded' do
      stub_request(:post, "#{base_url}/contacts/fields")
        .with(
          body: contact_field_data.to_json
        )
        .to_return(
          status: 429,
          body: { 'errors' => 'Rate limit exceeded' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { client.create(contact_field_data) }.to raise_error(Mailtrap::Error)
    end

    it 'raises error when validation fails' do
      invalid_data = { name: '', data_type: 'invalid_type', merge_tag: 'tag' }
      stub_request(:post, "#{base_url}/contacts/fields")
        .with(
          body: invalid_data.to_json
        )
        .to_return(
          status: 422,
          body: { 'errors' => { 'name' => ['cannot be blank'],
                                'data_type' => ['is not included in the list'] } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { client.create(invalid_data) }.to raise_error(Mailtrap::Error)
    end
  end

  describe '#update' do
    let(:contact_field_id) { 2 }
    let(:update_data) do
      {
        name: 'Updated Age',
        merge_tag: 'updated_age'
      }
    end
    let(:expected_response) do
      { 'id' => 2, 'name' => 'Updated Age', 'data_type' => 'integer', 'merge_tag' => 'updated_age' }
    end

    it 'updates a contact field' do
      stub_request(:patch, "#{base_url}/contacts/fields/#{contact_field_id}")
        .with(
          body: update_data.to_json
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.update(contact_field_id, update_data)
      expect(response).to have_attributes(id: 2, name: 'Updated Age', data_type: 'integer', merge_tag: 'updated_age')
    end

    it 'raises error when contact field not found' do
      stub_request(:patch, "#{base_url}/contacts/fields/999")
        .with(
          body: update_data.to_json
        )
        .to_return(
          status: 404,
          body: { 'error' => 'Not Found' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { client.update(999, update_data) }.to raise_error(Mailtrap::Error)
    end

    it 'raises error when data_type is set' do
      invalid_data = { name: 'Updated Age', data_type: 'invalid_type' }
      stub_request(:patch, "#{base_url}/contacts/fields/#{contact_field_id}")
        .with(
          body: invalid_data.to_json
        )

      expect { client.update(contact_field_id, invalid_data) }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    let(:contact_field_id) { 1 }

    it 'deletes a contact field' do
      stub_request(:delete, "#{base_url}/contacts/fields/#{contact_field_id}")
        .to_return(status: 204)

      response = client.delete(contact_field_id)
      expect(response).to be_nil
    end

    it 'raises error when contact field not found' do
      stub_request(:delete, "#{base_url}/contacts/fields/999")
        .to_return(
          status: 404,
          body: { 'error' => 'Not Found' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { client.delete(999) }.to raise_error(Mailtrap::Error)
    end

    it 'raises error when unauthorized' do
      stub_request(:delete, "#{base_url}/contacts/fields/#{contact_field_id}")
        .to_return(
          status: 401,
          body: { 'error' => 'Unauthorized' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { client.delete(contact_field_id) }.to raise_error(Mailtrap::AuthorizationError)
    end
  end
end
