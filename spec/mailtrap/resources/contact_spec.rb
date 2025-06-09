# frozen_string_literal: true

require 'spec_helper'
require 'mailtrap/api/client'
require 'mailtrap/resources/contact'

RSpec.describe Mailtrap::Resources::Contact do
  let(:client) { instance_double(Mailtrap::Api::Client) }
  let(:resource) { described_class.new(client, strict_mode: true) }
  let(:account_id) { '12345' }
  let(:contact_id) { 'abc-uuid-xyz' }

  let(:valid_contact) do
    {
      id: contact_id,
      status: 'active',
      email: 'user@example.com',
      fields: { name: 'John' },
      list_ids: ['list-1', 'list-2'],
      created_at: 1_716_400_000,
      updated_at: 1_716_400_000
    }
  end

  describe '#list' do
    let(:response_data) { { data: [valid_contact] } }

    it 'returns contact list with valid keys' do
      expect(client).to receive(:get).with(
        "/api/accounts/#{account_id}/contacts",
        params: { page: 1, per_page: 50 }
      ).and_return(response_data)

      expect(resource.list(account_id: account_id)).to eq(response_data)
    end

    it 'raises error for unexpected key in strict mode' do
      bad_data = { data: [valid_contact.merge(bad: 'extra')] }
      allow(client).to receive(:get).and_return(bad_data)

      expect {
        resource.list(account_id: account_id)
      }.to raise_error(ArgumentError, /Unexpected key in response: bad/)
    end

    it 'raises error for missing required key in strict mode' do
      incomplete = { data: [valid_contact.except(:email)] }
      allow(client).to receive(:get).and_return(incomplete)

      expect {
        resource.list(account_id: account_id)
      }.to raise_error(ArgumentError, /Missing key in contact object: email/)
    end
  end

  describe '#find' do
    it 'returns a single contact with valid keys' do
      expect(client).to receive(:get).with(
        "/api/accounts/#{account_id}/contacts/#{contact_id}"
      ).and_return(valid_contact)

      expect(resource.find(account_id: account_id, contact_id: contact_id)).to eq(valid_contact)
    end
  end

  describe '#create' do
    let(:params) { { email: 'new@example.com', fields: { name: 'Test' }, list_ids: ['list-1'] } }

    it 'creates a contact with allowed keys' do
      expect(client).to receive(:post).with(
        "/api/accounts/#{account_id}/contacts",
        body: { contact: params }
      ).and_return(valid_contact)

      expect(resource.create(account_id: account_id, **params)).to eq(valid_contact)
    end

    it 'raises error for extra key in strict mode' do
      expect {
        resource.create(account_id: account_id, email: 'x', foo: 'bar')
      }.to raise_error(ArgumentError, /Unexpected key in payload: foo/)
    end
  end

  describe '#update' do
    let(:update_params) do
      {
        email: 'updated@example.com',
        list_ids_included: ['list-2'],
        list_ids_excluded: [],
        unsubscribed: false,
        fields: { company: 'Acme' }
      }
    end

    it 'updates a contact' do
      expect(client).to receive(:patch).with(
        "/api/accounts/#{account_id}/contacts/#{contact_id}",
        body: { contact: update_params }
      ).and_return(valid_contact)

      expect(resource.update(account_id: account_id, contact_id: contact_id, **update_params)).to eq(valid_contact)
    end

    it 'raises error for unexpected update key' do
      expect {
        resource.update(account_id: account_id, contact_id: contact_id, something: 'bad')
      }.to raise_error(ArgumentError, /Unexpected key in payload: something/)
    end
  end

  describe '#delete' do
    it 'deletes a contact' do
      expect(client).to receive(:delete).with(
        "/api/accounts/#{account_id}/contacts/#{contact_id}"
      ).and_return({})

      expect(resource.delete(account_id: account_id, contact_id: contact_id)).to eq({})
    end
  end
end