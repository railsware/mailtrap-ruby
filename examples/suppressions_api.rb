require 'mailtrap'

client = Mailtrap::Client.new(api_key: 'your-api-key')
suppressions = Mailtrap::SuppressionsAPI.new 3229, client

# Set your API credentials as environment variables
# export MAILTRAP_API_KEY='your-api-key'
# export MAILTRAP_ACCOUNT_ID=your-account-id
#
# suppressions = Mailtrap::SuppressionsAPI.new

# Get all suppressions
list = suppressions.list
# =>
#  [
#    Mailtrap::Suppression.new(
#      id: "64d71bf3-1276-417b-86e1-8e66f138acfe",
#      type: "unsubscription",
#      created_at: "2024-12-26T09:40:44.161Z",
#      email: "recipient@example.com",
#      sending_stream: "transactional",
#      domain_name: "sender.com",
#      message_bounce_category: nil,
#      message_category: "Welcome email",
#      message_client_ip: "123.123.123.123",
#      message_created_at: "2024-12-26T07:10:00.889Z",
#      message_outgoing_ip: "1.1.1.1",
#      message_recipient_mx_name: "Other Providers",
#      message_sender_email: "hello@sender.com",
#      message_subject: "Welcome!"
#    )
#  ]

# Delete a suppression
suppressions.delete(list.first.id)
