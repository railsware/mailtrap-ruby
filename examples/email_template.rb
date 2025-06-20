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

created = templates.create(
  name: 'Welcome Email',
  subject: 'Welcome to Mailtrap!',
  body_html: '<h1>Hello</h1>',
  body_text: 'Hello',
  category: 'welcome'
)

puts "Created Template: #{created[:id]}"

list = templates.list
puts "Templates: #{list}"

found = templates.get(created[:id])
puts "Found Template: #{found[:name]}"

updated = templates.update(created[:id], name: 'Welcome Updated')
puts "Updated Template Name: #{updated[:name]}"

# Delete
templates.delete(created[:id])
puts 'Template deleted'

# create template using DTOs
template_request = Mailtrap::EmailTemplateRequest.new
template_request.name = 'Welcome Email'
template_request.subject = 'Welcome to Mailtrap!'
template_request.body_html = '<h1>Hello</h1>'
template_request.body_text = 'Hello'
template_request.category = 'welcome'

created = templates.create(template_request)
template_request.name = 'Welcome Email Updated DTO'
updated = templates.update(created.id, template_request)

puts "Updated Template Name: #{updated.name}"

templates.delete(created.id)

# create template using DTOs with hash
template_request = Mailtrap::EmailTemplateRequest.new(
  name: 'Welcome Email',
  subject: 'Welcome to Mailtrap!',
  body_html: '<h1>Hello</h1>',
  body_text: 'Hello',
  category: 'welcome'
)

created = templates.create(template_request)

templates.delete(created.id)
