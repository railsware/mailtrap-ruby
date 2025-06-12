# frozen_string_literal: true
require_relative '../lib/mailtrap'
require 'dotenv/load'
require 'base64'

client = Mailtrap::Client.new(
  api_key: ENV['MAILTRAP_API_KEY'],
  api_host: 'bulk.api.mailtrap.io'
)

batch = Mailtrap::BatchSender.new(client)

html_content = '<h1>Hello User</h1>'
text_content = 'Hello User'

base_payload = {
  from: { email: 'noreply@example.com', name: 'NoReply Bot' },
  subject: 'System Notification',
  html: html_content,
  text: text_content,
  attachments: [
    {
      filename: 'test.txt',
      content: Base64.strict_encode64('This is a test')
    }
  ],
  category: 'system',
  headers: { 'X-Custom-Header' => 'BatchSend' },
  track_opens: true,
  track_clicks: false
}

requests = [
  {
    to: [{ email: 'user1@example.com', name: 'User One' }],
    cc: [{ email: 'cc1@example.com' }],
    custom_variables: { user_id: 'u1' }
  },
  {
    to: [{ email: 'user2@example.com' }],
    bcc: [{ email: 'bcc@example.com' }],
    custom_variables: { user_id: 'u2' }
  }
]

batch.send_emails(base: base_payload, requests: requests)

puts "Batch email sent"
