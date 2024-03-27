require 'mailtrap'

# create mail object
mail = Mailtrap::Mail::FromTemplate.new(
  from: { email: 'mailtrap@example.com', name: 'Mailtrap Test' },
  to: [
    { email: 'your@email.com' }
  ],
  template_uuid: '2f45b0aa-bbed-432f-95e4-e145e1965ba2',
  template_variables: {
    'user_name' => 'John Doe'
  }
)

# create client and send
client = Mailtrap::Client.new(api_key: 'your-api-key')
client.send(mail)
