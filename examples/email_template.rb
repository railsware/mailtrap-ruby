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

templates = Mailtrap::EmailTemplatesAPI.new(1_111_111, client)

created_email_template = templates.create(
  name: 'Welcome Email',
  subject: 'Welcome to Mailtrap!',
  body_html: '<h1>Hello</h1>',
  body_text: 'Hello',
  category: 'welcome'
)

puts "Created Template: #{created_email_template.id}"

list = templates.list
puts "Templates: #{list}"

email_template = templates.get(created_email_template.id)
puts "Found Template: #{email_template.name}"

updated_email_template = templates.update(email_template.id, name: 'Welcome Updated')
puts "Updated Template Name: #{updated_email_template.name}"

updated_email_template = templates.update(email_template.id, body_html: nil)
puts "Updated body_html: #{updated_email_template.body_html}"

# Delete
templates.delete(email_template.id)
puts 'Template deleted'
