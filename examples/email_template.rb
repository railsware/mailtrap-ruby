require 'mailtrap'

# Create mail object
mail = Mailtrap::Mail.from_template(
  from: { email: 'mailtrap@example.com', name: 'Mailtrap Test' },
  to: [
    { email: 'your@email.com' }
  ],
  reply_to: { email: 'support@example.com', name: 'Mailtrap Reply-To' },
  template_uuid: '2f45b0aa-bbed-432f-95e4-e145e1965ba2',
  template_variables: {
    'user_name' => 'John Doe'
  }
)

# Create client and send
client = Mailtrap::Client.new(api_key: 'your-api-key')
client.send(mail)

# You can also pass the request parameters directly
client.send(
  from: { email: 'mailtrap@example.com', name: 'Mailtrap Test' },
  to: [
    { email: 'your@email.com' },
  ],
  template_uuid: '2f45b0aa-bbed-432f-95e4-e145e1965ba2',
  template_variables: {
    'user_name' => 'John Doe'
  }
)
