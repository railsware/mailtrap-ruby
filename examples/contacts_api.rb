require 'mailtrap'
account_id = 1_111_111
client = Mailtrap::Client.new(api_key: 'your-api-key')

contact_list = Mailtrap::ContactListsAPI.new(account_id, client)
list = contact_list.create(name: 'Test List')

contacts = Mailtrap::ContactsAPI.new(account_id, client)
contact = contacts.create(email: 'test@example.com', fields: { first_name: 'John Doe' }, list_ids: [list.id])
puts "Created Contact: #{contact.id}"

contact = contacts.get(contact.id)
puts "Contact: #{contact.email}"

contact = contacts.update(contact.id, email: 'test2@example.com', fields: { first_name: 'Jane Doe' }, list_ids: [2])
puts "Updated Contact: #{contact.data.email}"

contacts.delete(contact.data.id)
puts 'Contact deleted'

lists = contact_list.list
puts "Contact Lists: #{lists}"

contact_list.update(list.id, name: 'Test List Updated')

list = contact_list.get(list.id)
puts "Contact List: #{list.name}"

contact_list.delete(list.id)
puts 'Contact List deleted'
