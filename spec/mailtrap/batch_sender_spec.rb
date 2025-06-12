# frozen_string_literal: true

require 'spec_helper'
require 'mailtrap/client'
require 'mailtrap/batch_sender'
require 'mailtrap/batch/base'
require 'mailtrap/validators/email_validator'

RSpec.describe Mailtrap::BatchSender do
  let(:client) do
    Mailtrap::Client.new(
      api_key: 'test-token',
      bulk: true
    )
  end

  let(:sender) { described_class.new(client) }

  let(:base) do
    Mailtrap::Mail::Base.new(
      from: { email: 'from@example.com' },
      subject: 'Test',
      html: '<h1>Hello</h1>',
      text: 'Hello!'
    )
  end

  let(:requests) do
    [
      { to: [{ email: 'user1@example.com' }] },
      { to: [{ email: 'user2@example.com' }] }
    ]
  end

  describe '#send_emails' do
    it 'raises if client is not using bulk host' do
      client = Mailtrap::Client.new(api_key: 'test-token') # bulk: false
      sender = described_class.new(client)

      expect do
        sender.send_emails(base:, requests:)
      end.to raise_error(ArgumentError, /bulk.api.mailtrap.io/)
    end

    it 'raises if base.from is invalid' do
      expect do
        Mailtrap::Batch::Base.new(
          from: { email: 'bad' },
          subject: 'Test',
          html: '<h1>Hello</h1>',
          text: 'Hello!'
        )
      end.to raise_error(ArgumentError, /Invalid from\[:email\]/)
    end

    it 'raises if requests are missing or too big' do
      expect do
        sender.send_emails(base:, requests: [])
      end.to raise_error(ArgumentError, /non-empty Array/)

      many = Array.new(501) { { to: [{ email: 'u@example.com' }] } }

      expect do
        sender.send_emails(base:, requests: many)
      end.to raise_error(ArgumentError, /max 500/)
    end

    it 'raises on invalid recipient email' do
      bad_requests = [{ to: [{ email: 'bad' }] }]

      expect do
        sender.send_emails(base:, requests: bad_requests)
      end.to raise_error(ArgumentError, /Invalid to\[.*\]/)
    end

    it 'sends batch correctly and parses response' do
      response = {
        responses: [{ status: 202 }]
      }

      allow(client).to receive(:batch_send).and_return(response)

      result = sender.send_emails(base:, requests:)
      expect(result).to eq(response)
    end

    it 'raises if response is not valid hash' do
      allow(client).to receive(:batch_send).and_return('not a hash')

      expect do
        sender.send_emails(base:, requests:)
      end.to raise_error(Mailtrap::InvalidApiResponseError)
    end
  end

  it 'raises if base is not a Hash or object with #as_json' do
    expect do
      sender.send_emails(base: 123, requests:)
    end.to raise_error(ArgumentError, /Expected Hash or object with #as_json/)
  end

  it 'converts base using as_json if base responds to it' do
    dummy_base = double('Base', as_json: base.as_json)

    allow(client).to receive(:batch_send).and_return({ responses: [] })

    result = sender.send_emails(base: dummy_base, requests:)
    expect(result[:responses]).to eq([])
  end

  it 'skips validation if to/cc/bcc are not arrays' do
    requests_with_scalar_to = [{ to: { email: 'user@example.com' } }]

    allow(client).to receive(:batch_send).and_return({ responses: [] })

    expect do
      sender.send_emails(base:, requests: requests_with_scalar_to)
    end.not_to raise_error
  end

  it 'accepts empty cc and bcc arrays' do
    clean_requests = [{ to: [{ email: 'user@example.com' }], cc: [], bcc: [] }]

    allow(client).to receive(:batch_send).and_return({ responses: [] })

    result = sender.send_emails(base:, requests: clean_requests)
    expect(result[:responses]).to eq([])
  end

  it 'raises if recipient is missing :email key' do
    bad_requests = [{ to: [{}] }]

    expect do
      sender.send_emails(base:, requests: bad_requests)
    end.to raise_error(ArgumentError, /Invalid to\[.*\]/)
  end

  it 'raises if response does not contain responses array' do
    allow(client).to receive(:batch_send).and_return({ success: true })

    expect do
      sender.send_emails(base:, requests:)
    end.to raise_error(Mailtrap::InvalidApiResponseError)
  end
end