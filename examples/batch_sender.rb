# frozen_string_literal: true

require_relative '../lib/mailtrap'
require 'base64'

API_KEY = 'your-real-mailtrap-api-key-here'
API_KEY = '66625775e0dcd763c981e72edbe29d2f'

client = Mailtrap::Client.new(
  api_key: API_KEY,
  bulk: true
)

batch = Mailtrap::BatchSender.new(client)

base_mail = Mailtrap::Batch::Base.new(
  from: { email: 'noreply@example.com', name: 'NoReply Bot' },
  reply_to: { email: 'reply@example.com', name: 'Reply' },
  subject: 'System Notification',
  html: '<h1>Hello User</h1>',
  text: 'Hello User',
  category: 'system',
  headers: { 'X-Custom-Header' => 'BatchSend' },
  attachments: [
    {
      filename: 'test.txt',
      content: Base64.strict_encode64('This is a test')
    }
  ],
)

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

response = batch.send_emails(base: base_mail, requests: requests)

puts "Batch email sent:"
puts response