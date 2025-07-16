require 'mailtrap'

client = Mailtrap::Client.new(api_key: 'your-api-key')
contact_list = Mailtrap::ContactListsAPI.new 3229, client
contacts = Mailtrap::ContactsAPI.new 3229, client
contact_fields = Mailtrap::ContactFieldsAPI.new 3229, client

# Set your API credentials as environment variables
# export MAILTRAP_API_KEY='your-api-key'
# export MAILTRAP_ACCOUNT_ID=your-account-id
#
# contact_list = Mailtrap::ContactListsAPI.new
# contacts = Mailtrap::ContactsAPI.new
# contact_fields = Mailtrap::ContactFieldsAPI.new

# Create new contact list
list = contact_list.create(name: 'Test List')

# Get all contact lists
contact_list.list

# Update contact list
contact_list.update(list.id, name: 'Test List Updated')

# Get contact list
list = contact_list.get(list.id)

# Create new contact field
field = contact_fields.create(name: 'Nickname', data_type: 'text', merge_tag: 'nickname')

# Get all contact fields
contact_fields.list

# Update contact field
contact_fields.update(field.id, name: 'Nickname 2', merge_tag: 'nickname')

# Get contact field
field = contact_fields.get(field.id)

# Create new contact
contact = contacts.create(email: 'test@example.com', fields: { field.merge_tag => 'John Doe' }, list_ids: [list.id])
contact.newly_created? # => true

# Get contact
contact = contacts.get(contact.id)

# Update contact using id
updated_contact = contacts.upsert(contact.id, email: 'test2@example.com', fields: { field.merge_tag => 'Jane Doe' })
updated_contact.newly_created? # => false

# Update contact using email
contacts.upsert(updated_contact.email, email: 'test3@example.com', fields: { field.merge_tag => 'Jane Doe' })
updated_contact.newly_created? # => false

# Remove contact from lists
contacts.remove_from_lists(contact.id, [list.id])

# Add contact to lists
contacts.add_to_lists(contact.id, [list.id])

# Delete contact
contacts.delete(contact.id)

# Delete contact list
contact_list.delete(list.id)

# Delete contact field
contact_fields.delete(field.id)
