require 'mailtrap'
require 'base64'

client = Mailtrap::Client.new(api_key: 'your-api-key')

# Set your API credentials as environment variables
# export MAILTRAP_API_KEY='your-api-key'
#
# client = Mailtrap::Client.new
# Bulk sending (@see https://help.mailtrap.io/article/113-sending-streams)
# client = Mailtrap::Client.new(bulk: true)
# Sandbox sending (@see https://help.mailtrap.io/article/109-getting-started-with-mailtrap-email-testing)
# client = Mailtrap::Client.new(sandbox: true, inbox_id: 12)

# Batch sending with text and html content
batch_base = Mailtrap::Mail.batch_base_from_content(
  from: { email: 'mailtrap@demomailtrap.co', name: 'Mailtrap Test' },
  subject: 'You are awesome!',
  text: 'Congrats for sending test email with Mailtrap!',
  html: '<p>Congrats for sending test email with Mailtrap!</p>'
)

File.open('attachment.txt') do |f|
  batch_base.add_attachment(content: f, filename: 'attachment.txt')
end

client.send_batch(
  batch_base, [
    Mailtrap::Mail.from_content(
      to: [
        { email: 'john.doe@email.com', name: 'John Doe' }
      ]
    ),
    Mailtrap::Mail::Base.new(
      to: [
        { email: 'jane.doe@email.com', name: 'Jane Doe' }
      ]
    ),
    {
      to: [
        { email: 'david.doe@email.com', name: 'David Doe' }
      ]
    }
  ]
)

# Batch sending with template
batch_base = Mailtrap::Mail.batch_base_from_template(
  from: { email: 'mailtrap@demomailtrap.co', name: 'Mailtrap Test' },
  reply_to: { email: 'support@example.com', name: 'Mailtrap Reply-To' },
  template_uuid: '339c8ab0-e73c-4269-984e-0d2446aacf2c'
)

client.send_batch(
  batch_base, [
    Mailtrap::Mail.from_template(
      to: [
        { email: 'john.doe@email.com', name: 'John Doe' }
      ],
      template_variables: {
        user_name: 'John Doe'
      }
    ),
    Mailtrap::Mail::Base.new(
      to: [
        { email: 'jane.doe@email.com', name: 'Jane Doe' }
      ],
      template_variables: {
        user_name: 'Jane Doe'
      }
    ),
    {
      to: [
        { email: 'david.doe@email.com', name: 'David Doe' }
      ],
      template_variables: {
        user_name: 'David Doe'
      }
    }
  ]
)

# You can also pass the request parameters directly
client.send_batch(
  {
    from: { email: 'mailtrap@demomailtrap.co', name: 'Mailtrap Test' },
    reply_to: { email: 'support@example.com', name: 'Mailtrap Reply-To' },
    template_uuid: '339c8ab0-e73c-4269-984e-0d2446aacf2c'
  }, [
    {
      to: [
        { email: 'john.doe@email.com', name: 'John Doe' }
      ],
      template_variables: {
        user_name: 'John Doe'
      }
    },
    {
      to: [
        { email: 'jane.doe@email.com', name: 'Jane Doe' }
      ],
      template_variables: {
        user_name: 'Jane Doe'
      }
    },
    {
      to: [
        { email: 'david.doe@email.com', name: 'David Doe' }
      ],
      template_variables: {
        user_name: 'David Doe'
      }
    }
  ]
)
