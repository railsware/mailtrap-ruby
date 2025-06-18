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

# Delete a suppression
suppressions.delete(list.first.id)
