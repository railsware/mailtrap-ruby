require 'mailtrap'

client = Mailtrap::EmailTemplates.new(api_key: 'your-api-key')
account_id = 1

# list templates
client.all(account_id:)

# create template
created = client.create(
  account_id:,
  name: 'Newsletter Template',
  subject: 'Subject',
  category: 'Newsletter',
  body_html: '<div>Hello</div>'
)

# update template
client.update(
  account_id:,
  email_template_id: created[:id],
  name: 'Updated Template'
)

# delete template
client.delete(account_id:, email_template_id: created[:id])
