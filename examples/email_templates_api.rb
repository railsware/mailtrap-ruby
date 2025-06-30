require 'mailtrap'

client = Mailtrap::Client.new(api_key: 'your-api-key')
templates = Mailtrap::EmailTemplatesAPI.new 3229, client

# Set your API credentials as environment variables
# export MAILTRAP_API_KEY='your-api-key'
# export MAILTRAP_ACCOUNT_ID=your-account-id
#
# templates = Mailtrap::EmailTemplatesAPI.new

# Get all email templates
templates.list

# Create a new email template
email_template = templates.create(
  name: 'Welcome Email',
  subject: 'Welcome to Mailtrap!',
  body_html: '<h1>Hello</h1>',
  body_text: 'Hello',
  category: 'welcome'
)

# Get an email template
email_template = templates.get(email_template.id)

# Update an email template
email_template = templates.update(email_template.id, name: 'Welcome Updated')

# Delete an email template
templates.delete(email_template.id)
