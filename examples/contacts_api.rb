require 'mailtrap'

client = Mailtrap::Client.new(api_key: 'your-api-key')
contact_lists = Mailtrap::ContactListsAPI.new 3229, client
contacts = Mailtrap::ContactsAPI.new 3229, client
contact_fields = Mailtrap::ContactFieldsAPI.new 3229, client

# Set your API credentials as environment variables
# export MAILTRAP_API_KEY='your-api-key'
# export MAILTRAP_ACCOUNT_ID=your-account-id

# contact_lists = Mailtrap::ContactListsAPI.new
# contacts = Mailtrap::ContactsAPI.new
# contact_fields = Mailtrap::ContactFieldsAPI.new

# Create new contact list
list = contact_lists.create(name: 'Test List')
# => ContactList.new(id: 1, name: 'Test List')

# Get all contact lists
contact_lists.list
# => [ContactList.new(id: 1, name: 'Test List')]

# Update contact list
contact_lists.update(list.id, name: 'Test List Updated')
# => ContactList.new(id: 1, name: 'Test List Updated')

# Get contact list
list = contact_lists.get(list.id)
# => ContactList.new(id: 1, name: 'Test List Updated')

# Create new contact field
field = contact_fields.create(name: 'Nickname', data_type: 'text', merge_tag: 'nickname')
# => ContactField.new(id: 1, name: 'Nickname', data_type: 'text', merge_tag: 'nickname')

# Get all contact fields
contact_fields.list
# => [ContactField.new(id: 1, name: 'Nickname', data_type: 'text', merge_tag: 'nickname')]

# Update contact field
contact_fields.update(field.id, name: 'Nickname 2', merge_tag: 'nickname')
# => ContactField.new(id: 1, name: 'Nickname 2', data_type: 'text', merge_tag: 'nickname')

# Get contact field
field = contact_fields.get(field.id)
# => ContactField.new(id: 1, name: 'Nickname 2', data_type: 'text', merge_tag: 'nickname')

# Create new contact with all possible fields
contact = contacts.create(
  email: 'test@example.com',
  fields: { field.merge_tag => 'John Doe' },
  list_ids: [list.id]
)
# => Contact.new(
#      id: 1,
#      email: 'test@example.com',
#      fields: { 'nickname' => 'John Doe' },
#      list_ids: [1],
#      status: 'subscribed',
#      created_at: 1721212345,
#      updated_at: 1721212345
#    )
contact.newly_created? # => true

# Get contact
contact = contacts.get(contact.id)
# => Contact.new(
#      id: 1,
#      email: 'test@example.com',
#      fields: { 'nickname' => 'John Doe' },
#      list_ids: [1],
#      status: 'subscribed',
#      created_at: 1721212345,
#      updated_at: 1721212345
#    )

# Update contact using id
updated_contact = contacts.upsert(
  contact.id,
  email: 'test2@example.com',
  fields: { field.merge_tag => 'Jane Doe' }
)
# => Contact.new(
#      id: 1,
#      email: 'test2@example.com',
#      fields: { 'nickname' => 'Jane Doe' },
#      list_ids: [1],
#      status: 'subscribed',
#      created_at: 1721212345,
#      updated_at: 1721212350
#    )
updated_contact.newly_created? # => false

# Update contact using email
contacts.upsert(
  updated_contact.email,
  email: 'test3@example.com',
  fields: { field.merge_tag => 'Jane Doe' }
)
# => Contact.new(
#      id: 1,
#      email: 'test3@example.com',
#      fields: { 'nickname' => 'Jane Doe' },
#      list_ids: [1],
#      status: 'subscribed',
#      created_at: 1721212345,
#      updated_at: 1721212355
#    )
updated_contact.newly_created? # => false

# Remove contact from lists
contacts.remove_from_lists(contact.id, [list.id])
# => Contact.new(
#      id: 1,
#      email: 'test3@example.com',
#      fields: { 'nickname' => 'Jane Doe' },
#      list_ids: [],
#      status: 'subscribed',
#      created_at: 1721212345,
#      updated_at: 1721212360
#    )

# Add contact to lists
contacts.add_to_lists(contact.id, [list.id])
# => Contact.new(
#      id: 1,
#      email: 'test3@example.com',
#      fields: { 'nickname' => 'Jane Doe' },
#      list_ids: [1],
#      status: 'subscribed',
#      created_at: 1721212345,
#      updated_at: 1721212365
#    )

# Delete contact
contacts.delete(contact.id)

# Delete contact list
contact_lists.delete(list.id)

# Delete contact field
contact_fields.delete(field.id)
