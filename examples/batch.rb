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

# Batch sending with Mailtrap::Mail::Base
mail = Mailtrap::Mail::Base.new(
  from: { email: 'mailtrap@demomailtrap.co', name: 'Mailtrap Test' },
  subject: 'You are awesome!',
  text: 'Congrats for sending test email with Mailtrap!',
  category: 'Integration Test',
  attachments: [
    {
      content: Base64.encode64('Attachment content'), # base64 encoded content or IO string
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

client.send_batch(mail, [
                    Mailtrap::Mail::Base.new(
                      to: [
                        { email: 'your@email.com', name: 'recipient1' }
                      ]
                    ),
                    Mailtrap::Mail::Base.new(
                      to: [
                        { email: 'your@email.com', name: 'recipient2' }
                      ]
                    )
                  ])

# Batch sending with Mailtrap::Mail::Base
mail = Mailtrap::Mail::Base.new(
  from: { email: 'mailtrap@demomailtrap.co', name: 'Mailtrap Test' },
  reply_to: { email: 'support@example.com', name: 'Mailtrap Reply-To' },
  template_uuid: '339c8ab0-e73c-4269-984e-0d2446aacf2c',
  template_variables: {
    'user_name' => 'John Doe'
  }
)

client.send_batch(mail, [
                    Mailtrap::Mail::Base.new(
                      to: [
                        { email: 'your@email.com', name: 'recipient1' }
                      ]
                    ),
                    Mailtrap::Mail::Base.new(
                      to: [
                        { email: 'your@email.com', name: 'recipient2' }
                      ],
                      template_variables: {
                        'user_name' => 'John Doe 1',
                        'user_name2' => 'John Doe 2'
                      }
                    )
                  ])
