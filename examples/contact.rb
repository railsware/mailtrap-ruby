# frozen_string_literal: true
require_relative '../lib/mailtrap'
require 'dotenv/load'

client = Mailtrap::Client.new(
  api_key: ENV['MAILTRAP_API_KEY'],
  api_host: 'sandbox.api.mailtrap.io'
)

contact = Mailtrap::Contact.new(client, strict_mode: true)

account_id = ENV['MAILTRAP_ACCOUNT_ID']

# Create
created = contact.create(
  account_id: account_id,
  email: 'john.doe@example.com',
  fields: { name: 'John Doe' },
  list_ids: ['your-list-id']
)
puts "Created Contact: #{created[:id]}"

# List
list = contact.list(account_id: account_id)
puts "Contacts: #{list[:data].size}"

# Find
found = contact.find(account_id: account_id, contact_id: created[:id])
puts "Found Contact: #{found[:email]}"

# Update
updated = contact.update(
  account_id: account_id,
  contact_id: created[:id],
  fields: { name: 'Johnny' },
  unsubscribed: false
)
puts "Updated Contact: #{updated[:fields]}"

# Delete
contact.delete(account_id: account_id, contact_id: created[:id])
puts "Contact deleted"