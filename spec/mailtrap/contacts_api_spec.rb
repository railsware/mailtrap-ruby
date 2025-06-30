# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mailtrap::ContactsAPI do
  let(:client) { described_class.new('1111111', Mailtrap::Client.new(api_key: 'correct-api-key')) }
  let(:base_url) { 'https://mailtrap.io/api/accounts/1111111' }
  let(:email) { 'test@example.com' }
  let(:contact_id) { '019706a8-9612-77be-8586-4f26816b467a' }

  describe '#get' do
    context 'when contact_id is a UUID' do
      let(:expected_response) do
        {
          'data' => {
            'id' => contact_id,
            'email' => email,
            'created_at' => 1_748_163_401_202,
            'updated_at' => 1_748_163_401_202,
            'list_ids' => [1, 2],
            'status' => 'subscribed',
            'fields' => {
              'first_name' => 'John',
              'last_name' => nil
            }
          }
        }
      end

      it 'returns contact by UUID' do
        stub_request(:get, "#{base_url}/contacts/#{contact_id}")
          .to_return(
            status: 200,
            body: expected_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        response = client.get(contact_id)
        expect(response).to have_attributes(
          email:,
          status: 'subscribed'
        )
      end
    end

    context 'when contact_id is an email' do
      let(:expected_response) do
        {
          'data' => {
            'id' => '019706a8-9612-77be-8586-4f26816b467a',
            'email' => email,
            'created_at' => 1_748_163_401_202,
            'updated_at' => 1_748_163_401_202,
            'list_ids' => [1, 2],
            'status' => 'subscribed',
            'fields' => {
              'first_name' => 'John',
              'last_name' => nil
            }
          }
        }
      end

      it 'returns contact by email' do
        stub_request(:get, "#{base_url}/contacts/#{CGI.escape(email)}")
          .to_return(
            status: 200,
            body: expected_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        response = client.get(email)
        expect(response).to have_attributes(email:)
      end

      it 'handles special characters in email' do
        special_email = 'test+special@example.com'
        stub_request(:get, "#{base_url}/contacts/#{CGI.escape(special_email)}")
          .to_return(
            status: 200,
            body: expected_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        response = client.get(special_email)
        expect(response).to have_attributes(email:)
      end
    end

    context 'when contact is not found' do
      it 'raises error for non-existent UUID' do
        stub_request(:get, "#{base_url}/contacts/non-existent-uuid")
          .to_return(
            status: 404,
            body: { 'error' => 'Not Found' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        expect { client.get('non-existent-uuid') }.to raise_error(Mailtrap::Error)
      end

      it 'raises error for non-existent email' do
        non_existent_email = 'nonexistent@example.com'
        stub_request(:get, "#{base_url}/contacts/#{CGI.escape(non_existent_email)}")
          .to_return(
            status: 404,
            body: { 'error' => 'Not Found' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        expect { client.get(non_existent_email) }.to raise_error(Mailtrap::Error)
      end
    end
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe '#create' do
    let(:contact_data) do
      {
        email:,
        fields: { first_name: 'John' },
        list_ids: [1, 2]
      }
    end
    let(:expected_response) do
      {
        'data' => {
          'id' => contact_id,
          'email' => email,
          'created_at' => 1_748_163_401_202,
          'updated_at' => 1_748_163_401_202,
          'list_ids' => [1, 2],
          'status' => 'subscribed',
          'fields' => {
            'first_name' => 'John',
            'last_name' => nil
          }
        }
      }
    end

    it 'creates a new contact' do
      stub_request(:post, "#{base_url}/contacts")
        .with(
          body: { contact: contact_data }.to_json
        )
        .to_return(
          status: 201,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.create(contact_data)
      expect(response).to have_attributes(email:)
    end

    it 'raises error for invalid contact data' do
      invalid_data = { email: 'invalid-email' }
      stub_request(:post, "#{base_url}/contacts")
        .with(
          body: { contact: invalid_data }.to_json
        )
        .to_return(
          status: 422,
          body: { 'errors' => { 'email' => ['is invalid'] } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { client.create(invalid_data) }.to raise_error(Mailtrap::Error)
    end
  end

  describe '#update' do
    let(:update_data) do
      {
        email:,
        fields: { last_name: 'Smith' },
        list_ids_included: [3],
        list_ids_excluded: [1, 2],
        unsubscribed: true
      }
    end
    let(:expected_response) do
      {
        'data' => {
          'id' => contact_id,
          'email' => email,
          'created_at' => 1_748_163_401_202,
          'updated_at' => 1_748_163_401_202,
          'list_ids' => [3],
          'status' => 'unsubscribed',
          'fields' => {
            'first_name' => 'John',
            'last_name' => 'Smith'
          }
        },
        'action' => 'updated'
      }
    end

    it 'contact by id' do
      stub_request(:patch, "#{base_url}/contacts/#{contact_id}")
        .with(
          body: { contact: update_data }.to_json
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      response = client.update(contact_id, update_data)

      expect(response).to have_attributes(
        data: have_attributes(
          id: contact_id,
          fields: include(
            last_name: 'Smith'
          )
        ),
        action: 'updated'
      )
    end

    it 'contact by email' do
      stub_request(:patch, "#{base_url}/contacts/#{CGI.escape(email)}")
        .with(
          body: { contact: update_data }.to_json
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.update(email, update_data)
      expect(response).to have_attributes(
        data: have_attributes(
          email:
        )
      )
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers

  describe '#delete' do
    it 'deletes contact by id' do
      stub_request(:delete, "#{base_url}/contacts/#{contact_id}")
        .to_return(status: 204)

      response = client.delete(contact_id)
      expect(response).to be_nil
    end

    it 'deletes contact by email' do
      stub_request(:delete, "#{base_url}/contacts/#{CGI.escape(email)}")
        .to_return(status: 204)

      response = client.delete(email)
      expect(response).to be_nil
    end
  end
end
