require 'mailtrap'

ENV['MAILTRAP_API_KEY'] ||= 'your-api-key'
ENV['MAILTRAP_ACCOUNT_ID'] ||= '1111111'

templates = Mailtrap::EmailTemplatesAPI.new # or Mailtrap::EmailTemplatesAPI.new(account_id, client)

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
