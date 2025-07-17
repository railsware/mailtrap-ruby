# frozen_string_literal: true

RSpec.describe Mailtrap::SuppressionsAPI do
  subject(:suppressions) { described_class.new(account_id, client) }

  let(:account_id) { ENV.fetch('MAILTRAP_ACCOUNT_ID', 1_111_111) }
  let(:client) { Mailtrap::Client.new(api_key: ENV.fetch('MAILTRAP_API_KEY', 'local-api-key')) }

  let(:base_url) { "https://mailtrap.io/api/accounts/#{account_id}" }

  describe '#list' do
    let(:expected_attributes) do
      {
        'id' => '123e4567-e89b-12d3-a456-426614174000',
        'type' => 'hard bounce',
        'created_at' => '2024-06-01T12:00:00Z',
        'email' => 'user1@example.com',
        'sending_stream' => 'transactional',
        'domain_name' => 'example.com',
        'message_bounce_category' => 'invalid recipient',
        'message_category' => 'transactional',
        'message_client_ip' => '192.0.2.1',
        'message_created_at' => '2024-06-01T11:59:00Z',
        'message_esp_response' => '550 5.1.1 User unknown',
        'message_esp_server_type' => 'smtp',
        'message_outgoing_ip' => '198.51.100.1',
        'message_recipient_mx_name' => 'mx.example.com',
        'message_sender_email' => 'sender@example.com',
        'message_subject' => 'Test subject'
      }
    end
    let(:expected_response) do
      [
        expected_attributes,
        {
          'id' => '456e7890-e89b-12d3-a456-426614174001',
          'type' => 'spam complaint',
          'created_at' => '2024-06-01T13:00:00Z',
          'email' => 'user2@example.com',
          'sending_stream' => 'bulk',
          'domain_name' => 'example.org',
          'message_bounce_category' => nil,
          'message_category' => 'bulk',
          'message_client_ip' => '192.0.2.2',
          'message_created_at' => '2024-06-01T12:59:00Z',
          'message_esp_response' => nil,
          'message_esp_server_type' => nil,
          'message_outgoing_ip' => '198.51.100.2',
          'message_recipient_mx_name' => 'mx.example.org',
          'message_sender_email' => 'sender2@example.com',
          'message_subject' => 'Bulk email subject'
        }
      ]
    end

    it 'returns all suppressions' do
      stub_request(:get, "#{base_url}/suppressions")
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = suppressions.list
      expect(response).to all(be_a(Mailtrap::Suppression))
      expect(response.length).to eq(2)
      expect(response.first).to have_attributes(expected_attributes)
    end

    it 'returns suppressions filtered by email' do
      email = 'user1@example.com'
      stub_request(:get, "#{base_url}/suppressions?email=#{email}")
        .to_return(
          status: 200,
          body: [expected_attributes].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = suppressions.list(email:)
      expect(response).to all(be_a(Mailtrap::Suppression))
      expect(response.length).to eq(1)
      expect(response.first).to have_attributes(expected_attributes)
    end

    it 'raises error when unauthorized' do
      stub_request(:get, "#{base_url}/suppressions")
        .to_return(
          status: 401,
          body: { 'error' => 'Unauthorized' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { suppressions.list }.to raise_error(Mailtrap::AuthorizationError)
    end
  end

  describe '#delete' do
    let(:suppression_id) { 1 }

    it 'deletes a suppression' do
      stub_request(:delete, "#{base_url}/suppressions/#{suppression_id}")
        .to_return(status: 204)

      response = suppressions.delete(suppression_id)
      expect(response).to be_nil
    end

    it 'raises error when suppression not found' do
      stub_request(:delete, "#{base_url}/suppressions/999")
        .to_return(
          status: 404,
          body: { 'error' => 'Not Found' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { suppressions.delete(999) }.to raise_error(Mailtrap::Error)
    end

    it 'raises error when unauthorized' do
      stub_request(:delete, "#{base_url}/suppressions/#{suppression_id}")
        .to_return(
          status: 401,
          body: { 'error' => 'Unauthorized' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { suppressions.delete(suppression_id) }.to raise_error(Mailtrap::AuthorizationError)
    end
  end

  describe 'vcr#list', :vcr do
    subject(:list) { suppressions.list }

    it 'maps response data to Suppression objects' do
      expect(list).to all(be_a(Mailtrap::Suppression))
      expect(list.first).to have_attributes(
        id: be_a(String),
        type: be_a(String),
        created_at: be_a(String),
        email: be_a(String),
        sending_stream: be_a(String),
        domain_name: be_a(String),
        message_bounce_category: be_a(String),
        message_category: be_a(String),
        message_client_ip: be_a(String)
      )
    end

    context 'when api key is incorrect' do
      let(:client) { Mailtrap::Client.new(api_key: 'incorrect-api-key') }

      it 'raises authorization error' do
        expect { list }.to raise_error do |error|
          expect(error).to be_a(Mailtrap::AuthorizationError)
          expect(error.message).to include('Incorrect API token')
          expect(error.messages.any? { |msg| msg.include?('Incorrect API token') }).to be true
        end
      end
    end
  end
end
