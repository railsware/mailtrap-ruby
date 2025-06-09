require 'spec_helper'
require 'mailtrap/api/client'
require 'mailtrap/batch_sender'

RSpec.describe Mailtrap::BatchSender do
  let(:api_client) { instance_double(Mailtrap::Api::Client) }
  let(:batch_sender) { described_class.new(api_client, strict_mode: true) }

  let(:base_payload) do
    {
      from: { email: 'sales@example.com', name: 'Sales Team' },
      reply_to: { email: 'reply@example.com', name: 'Support' },
      subject: 'Order Confirmation',
      text: 'Thanks for your order!',
      category: 'Transactional',
      headers: { 'X-Custom-Header' => 'custom value' },
      attachments: [
        {
          content: Base64.encode64('<html><body>Hello</body></html>'),
          filename: 'index.html',
          type: 'text/html',
          disposition: 'attachment'
        }
      ]
    }
  end

  let(:requests_payload) do
    [
      {
        to: [{ email: 'john@example.com', name: 'John' }],
        custom_variables: { user_id: '123', batch_id: 'A1' }
      },
      {
        to: [{ email: 'jane@example.com', name: 'Jane' }],
        custom_variables: { user_id: '456', batch_id: 'A1' }
      }
    ]
  end

  it 'sends batch emails with correct payload in strict mode' do
    expected_payload = { base: base_payload, requests: requests_payload }

    expect(api_client).to receive(:batch_send).with(expected_payload).once.and_return({ success: true })

    result = batch_sender.send_emails(base: base_payload, requests: requests_payload)
    expect(result).to eq(success: true)
  end

  it 'raises error on unexpected key in base' do
    base_with_extra = base_payload.merge(unexpected: 'value')
    expect {
      batch_sender.send_emails(base: base_with_extra, requests: requests_payload)
    }.to raise_error(ArgumentError, /Unexpected key in base: unexpected/)
  end

  it 'raises error on unexpected key in from' do
    base_with_extra_from = base_payload.dup
    base_with_extra_from[:from] = base_with_extra_from[:from].merge(bad_field: 'oops')

    expect {
      batch_sender.send_emails(base: base_with_extra_from, requests: requests_payload)
    }.to raise_error(ArgumentError, /Unexpected key in from: bad_field/)
  end

  it 'raises error on unexpected key in recipient' do
    bad_requests = [
      {
        to: [{ email: 'john@example.com', name: 'John', foo: 'bar' }],
        custom_variables: { user_id: '123' }
      }
    ]
  
    expect {
      batch_sender.send_emails(base: base_payload, requests: bad_requests)
    }.to raise_error(ArgumentError, /Unexpected key in to recipient: foo/)
  end  

  it 'raises error on unexpected key in request block' do
    bad_requests = [
      {
        to: [{ email: 'john@example.com' }],
        custom_variables: { user_id: '123' },
        unexpected_field: 'nope'
      }
    ]

    expect {
      batch_sender.send_emails(base: base_payload, requests: bad_requests)
    }.to raise_error(ArgumentError, /Unexpected key in request #1: unexpected_field/)
  end

  it 'accepts cc, bcc, template_uuid and template_variables in strict mode' do
    requests = [
      {
        to: [{ email: 'to@example.com' }],
        cc: [{ email: 'cc@example.com' }],
        bcc: [{ email: 'bcc@example.com' }],
        custom_variables: { key: 'val' },
        template_uuid: 'abc-123-uuid',
        template_variables: { username: 'John' }
      }
    ]

    expect(api_client).to receive(:batch_send).with(
      {
        base: base_payload,
        requests: requests
      }
    ).once.and_return({ success: true })
  
    result = batch_sender.send_emails(base: base_payload, requests: requests)
    expect(result).to eq(success: true)
  end
  
  it 'raises error if cc recipient has invalid extra key' do
    requests = [
      {
        to: [{ email: 'to@example.com' }],
        cc: [{ email: 'cc@example.com', foo: 'bad' }]
      }
    ]
  
    expect {
      batch_sender.send_emails(base: base_payload, requests: requests)
    }.to raise_error(ArgumentError, /Unexpected key in cc recipient: foo/)
  end

  it 'accepts track_opens and track_clicks in base' do
    updated_base = base_payload.merge(track_opens: true, track_clicks: false)

    expect(api_client).to receive(:batch_send).with(
      {
        base: updated_base,
        requests: requests_payload
      }
    ).once.and_return({ success: true })

    result = batch_sender.send_emails(base: updated_base, requests: requests_payload)
    expect(result).to eq(success: true)
  end

  it 'raises error when more than 500 requests are provided' do
    large_requests = Array.new(501) do |i|
      {
        to: [{ email: "user#{i}@example.com" }],
        custom_variables: { id: i }
      }
    end

    expect {
      batch_sender.send_emails(base: base_payload, requests: large_requests)
    }.to raise_error(ArgumentError, /Too many messages in batch: max 500 allowed/)
  end

  it 'raises error if attachment is missing filename' do
    broken_base = base_payload.dup
    broken_base[:attachments] = [{ content: Base64.encode64('data') }]

    expect {
      batch_sender.send_emails(base: broken_base, requests: requests_payload)
    }.to raise_error(ArgumentError, /missing 'filename'/i)
  end

  it 'raises error if attachment is missing content' do
    broken_base = base_payload.dup
    broken_base[:attachments] = [{ filename: 'file.txt' }]

    expect {
      batch_sender.send_emails(base: broken_base, requests: requests_payload)
    }.to raise_error(ArgumentError, /missing 'content'/i)
  end

  it 'raises error if total attachments size exceeds 50MB' do
    big_content = 'a' * (50 * 1024 * 1024 + 1)
    broken_base = base_payload.dup
    broken_base[:attachments] = [{ filename: 'big.txt', content: big_content }]

    expect {
      batch_sender.send_emails(base: broken_base, requests: requests_payload)
    }.to raise_error(ArgumentError, /Attachments exceed maximum allowed size/i)
  end
  
end