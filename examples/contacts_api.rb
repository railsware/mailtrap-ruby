require 'mailtrap'

client = Mailtrap::Client.new(api_key: 'your-api-key')
contact_list = Mailtrap::ContactListsAPI.new 3229, client
contacts = Mailtrap::ContactsAPI.new 3229, client

# Set your API credentials as environment variables
# export MAILTRAP_API_KEY='your-api-key'
# export MAILTRAP_ACCOUNT_ID=your-account-id
#
# contact_list = Mailtrap::ContactListsAPI.new
# contacts = Mailtrap::ContactsAPI.new

# Create new contact list
list = contact_list.create(name: 'Test List')

# Get all contact lists
contact_list.list

# Update contact list
contact_list.update(list.id, name: 'Test List Updated')

# Get contact list
list = contact_list.get(list.id)

# Create new contact
contact = contacts.create(email: 'test@example.com', fields: { first_name: 'John Doe' }, list_ids: [list.id])

# Get contact
contact = contacts.get(contact.id)

# Update contact using id
updated_contact = contacts.update(contact.id, email: 'test2@example.com', fields: { first_name: 'Jane Doe' },
                                              list_ids_excluded: [list.id])

# Update contact using email
contacts.update(updated_contact.data.email, email: 'test3@example.com', fields: { first_name: 'Jane Doe' },
                                            list_ids_included: [list.id])

# Delete contact
contacts.delete(contact.id)

# Delete contact list
contact_list.delete(list.id)
