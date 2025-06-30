# frozen_string_literal: true

RSpec.describe Mailtrap::Suppression do
  let(:attributes) do
    {
      id: '018dd5e3-f6d2-7c00-8f9b-e5c3f2d8a132',
      type: 'bounce',
      created_at: '2021-01-01T00:00:00Z',
      email: 'test@example.com',
      sending_stream: 'main',
      domain_name: 'example.com',
      message_bounce_category: 'hard_bounce',
      message_category: 'bounce',
      message_client_ip: '192.168.1.1',
      message_created_at: '2021-01-01T00:00:00Z',
      message_esp_response: '550 5.1.1 User unknown',
      message_esp_server_type: 'smtp',
      message_outgoing_ip: '10.0.0.1',
      message_recipient_mx_name: 'mx.example.com',
      message_sender_email: 'sender@example.com',
      message_subject: 'Test Email'
    }
  end

  describe '#initialize' do
    subject(:suppression) { described_class.new(attributes) }

    it 'creates a suppression with all attributes' do
      expect(suppression).to have_attributes(attributes)
    end
  end

  describe '#to_h' do
    subject(:hash) { suppression.to_h }

    let(:suppression) do
      described_class.new(attributes)
    end

    it 'returns a hash with all attributes' do
      expect(hash).to have_different_object_id_than(attributes)
      expect(hash).to eq(attributes)
    end
  end
end
