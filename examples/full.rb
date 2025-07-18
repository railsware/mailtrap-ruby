require 'mailtrap'
require 'base64'

# You can create a mail object using one of the following:
# - Mailtrap::Mail.from_content
# - Mailtrap::Mail.from_template
# - Mailtrap::Mail::Base.new
mail = Mailtrap::Mail.from_content(
  from: { email: 'mailtrap@example.com', name: 'Mailtrap Test' },
  to: [
    { email: 'your@email.com', name: 'Your name' }
  ],
  reply_to: { email: 'support@example.com', name: 'Mailtrap Reply-To' },
  cc: [
    { email: 'cc@email.com', name: 'Copy To' }
  ],
  bcc: [
    { email: 'bcc@email.com', name: 'Hidden Recipient' }
  ],
  subject: 'You are awesome!',
  text: 'Congrats for sending test email with Mailtrap!',
  category: 'Integration Test',
  attachments: [
    {
      content: Base64.strict_encode64('Attachment content'), # base64 encoded content or IO string
      filename: 'attachment.txt'
    }
  ],
  headers: {
    'X-MT-Header': 'Custom header'
  },
  custom_variables: {
    year: 2022
  }
)

data = File.read('/path/to/image.jpg')
encoded = Base64.encode64(data).gsub("\n", '')

mail.add_attachment(content: encoded, filename: 'image.png')

client = Mailtrap::Client.new(api_key: 'your-api-key')

# Set your API credentials as environment variables
# export MAILTRAP_API_KEY='your-api-key'
#
# client = Mailtrap::Client.new

# Custom host / port
# client = Mailtrap::Client.new(api_key: 'your-api-key', api_host: 'alternative.host.mailtrap.io', api_port: 8080)

# Bulk sending (@see https://help.mailtrap.io/article/113-sending-streams)
# client = Mailtrap::Client.new(api_key: 'your-api-key', bulk: true)

# Sandbox sending (@see https://help.mailtrap.io/article/109-getting-started-with-mailtrap-email-testing)
# client = Mailtrap::Client.new(api_key: 'your-api-key', sandbox: true, inbox_id: 12)

client.send(mail)

# You can also pass the request parameters directly
client.send(
  from: { email: 'mailtrap@example.com', name: 'Mailtrap Test' },
  to: [
    { email: 'your@email.com', name: 'Your name' }
  ],
  subject: 'You are awesome!',
  text: 'Congrats for sending test email with Mailtrap!'
)
