require 'bundler/setup'
require 'mailtrap'

# create mail object
mail = Mailtrap::Mail::FromTemplate.new(
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

# create client and send
client = Mailtrap::Client.new(api_key: 'your-api-key')
client.send(mail)

templates = Mailtrap::Template.new(1_111_111, client)

created = templates.create(
  name: 'Welcome Email',
  subject: 'Welcome to Mailtrap!',
  body_html: '<h1>Hello</h1>',
  body_text: 'Hello',
  category: 'welcome'
) # or Mailtrap::EmailTemplateRequest
puts "Created Template: #{created[:id]}"

list = templates.list
puts "Templates: #{list}"

found = templates.get(created[:id])
puts "Found Template: #{found[:name]}"

updated = templates.update(created[:id], name: 'Welcome Updated') # or Mailtrap::EmailTemplateRequest
puts "Updated Template Name: #{updated[:name]}"

# Delete
templates.delete(created[:id])
puts 'Template deleted'
