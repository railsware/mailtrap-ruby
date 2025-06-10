# frozen_string_literal: true
require_relative '../lib/mailtrap'
require 'dotenv/load'

client = Mailtrap::Client.new(
  api_key: ENV['MAILTRAP_API_KEY'],
  api_host: 'sandbox.api.mailtrap.io'
)

template = Mailtrap::Template.new(client, strict_mode: true)

account_id = ENV['MAILTRAP_ACCOUNT_ID']

# Create
created = template.create(
  account_id: account_id,
  name: 'Welcome Email',
  subject: 'Welcome to Mailtrap!',
  body_html: '<h1>Hello</h1>',
  body_text: 'Hello'
)
puts "Created Template: #{created[:id]}"

# List
list = template.list(account_id: account_id)
puts "Templates: #{list[:data].size}"

# Find
found = template.find(account_id: account_id, template_id: created[:id])
puts "Found Template: #{found[:name]}"

# Patch
updated = template.patch(account_id: account_id, template_id: created[:id], name: 'Welcome Updated')
puts "Updated Template Name: #{updated[:name]}"

# Delete
template.delete(account_id: account_id, template_id: created[:id])
puts "Template deleted"
