require 'mailtrap'

client = Mailtrap::Client.new(api_key: 'your-api-key')
contact_fields = Mailtrap::ContactFieldsAPI.new 3229, client

# Set your API credentials as environment variables
# export MAILTRAP_API_KEY='your-api-key'
# export MAILTRAP_ACCOUNT_ID=your-account-id
#
# contact_fields = Mailtrap::ContactFieldsAPI.new

# Create new contact field
field = contact_fields.create(name: 'Updated name', data_type: 'text', merge_tag: 'updated_name')

# Get all contact fields
contact_fields.list

# Update contact field
contact_fields.update(field.id, name: 'Updated name 2', merge_tag: 'updated_name_2')

# Get contact field
field = contact_fields.get(field.id)

# Delete contact field
contact_fields.delete(field.id)
