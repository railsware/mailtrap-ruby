require 'spec_helper'
require 'mailtrap/client'
require 'mailtrap/batch_sender'

RSpec.describe Mailtrap::BatchSender do
  let(:api_client) { instance_double(Mailtrap::Client) }
  let(:batch_sender) { described_class.new(api_client, strict_mode: true) }
  let(:non_strict_sender) { described_class.new(api_client, strict_mode: false) }

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

  it 'raises error when base is missing required keys' do
    invalid_base = base_payload.dup
    invalid_base.delete(:from)
  
    expect {
      batch_sender.send_emails(base: invalid_base, requests: requests_payload)
    }.to raise_error(ArgumentError, /Missing required base field: from/)
  end
  
  it 'logs warnings for unexpected keys in strict mode' do
    base_with_extra = base_payload.merge(extra_key: 'value')
  
    expect(batch_sender).to receive(:warn).with(/\[Mailtrap::BatchSender\] Unexpected key in base: extra_key/)
    allow(api_client).to receive(:batch_send).and_return({ success: true })
  
    batch_sender.send_emails(base: base_with_extra, requests: requests_payload)
  end

  it 'ignores unexpected keys in non-strict mode' do
    base_with_extra = base_payload.merge(unexpected: 'yes')

    expect(api_client).to receive(:batch_send).and_return({ success: true })

    expect {
      non_strict_sender.send_emails(base: base_with_extra, requests: requests_payload)
    }.not_to raise_error
  end
end