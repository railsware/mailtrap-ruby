require 'mailtrap'

client = Mailtrap::Client.new(api_key: 'your-api-key')
account_id = 1

# list templates
client.list_templates(account_id:)

# create template
created = client.create_template(
  account_id:,
  name: 'Newsletter Template',
  subject: 'Subject',
  category: 'Newsletter',
  body_html: '<div>Hello</div>'
)

# update template
client.update_template(
  account_id:,
  email_template_id: created[:id],
  name: 'Updated Template'
)

# delete template
client.destroy_template(account_id:, email_template_id: created[:id])
