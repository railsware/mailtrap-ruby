[![test](https://github.com/railsware/mailtrap-ruby/actions/workflows/main.yml/badge.svg)](https://github.com/railsware/mailtrap-ruby/actions/workflows/main.yml)
[![docs](https://shields.io/badge/docs-rubydoc.info-blue)](https://rubydoc.info/gems/mailtrap)
[![gem](https://shields.io/gem/v/mailtrap)](https://rubygems.org/gems/mailtrap)
[![downloads](https://shields.io/gem/dt/mailtrap)](https://rubygems.org/gems/mailtrap)
[![license](https://shields.io/badge/license-MIT-green)](https://opensource.org/licenses/MIT)

# Official Mailtrap Ruby client

## Prerequisites

To get the most out of this official Mailtrap.io Ruby SDK:

* [Create a Mailtrap account](https://mailtrap.io/signup)
* [Verify your domain](https://mailtrap.io/sending/domains)

## Supported functionality

This Ruby gem offers integration with the [official API](https://api-docs.mailtrap.io/) for [Mailtrap](https://mailtrap.io).

Quickly add email sending functionality to your Ruby application with Mailtrap.

(This client uses API v2, for v1 refer to [this documentation](https://mailtrap.docs.apiary.io/))

Currently, with this SDK you can:

* **Email API/SMTP**
    * Send an email (Transactional and Bulk streams)
    * Send an email with a template
    * Send a batch of emails (Transactional and Bulk streams)
* **Email Sandbox (Testing)**
    * Send an email
    * Send an email with a template
    * Message management
    * Inbox management
    * Project management
* **Contact management**
    * Contacts CRUD
    * Lists CRUD
    * Contact fields CRUD
* **General**
    * Templates CRUD
    * Suppressions management (find and delete)
    * Account access management
    * Permissions management
    * List accounts you have access to

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mailtrap'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mailtrap

## Usage

### Basic Setup

Before you start sending emails, you'll need:
- A [Mailtrap account](https://mailtrap.io/signup)
- A [verified domain](https://mailtrap.io/sending/domains) 
- An API key from your Mailtrap dashboard

Set your API key as an environment variable:
```bash
export MAILTRAP_API_KEY="your-api-key"
```

### Minimal

```ruby
require 'mailtrap'

# For this example to work, you need to set up a sending domain,
# and obtain a token that is authorized to send from the domain.

client = Mailtrap::Client.new(api_key: 'your-api-key')

client.send(
  from: { email: 'mailtrap@example.com', name: 'Mailtrap Test' },
  to: [{ email: 'your@email.com' }],
  subject: 'Hello from Mailtrap!',
  text: 'Welcome to Mailtrap Sending!'
)
```

### Ruby on Rails

```ruby
# config/environments/production.rb
config.action_mailer.delivery_method = :mailtrap

# Set the MAILTRAP_API_KEY environment variable
# using your hosting solution, or customize the settings:
config.action_mailer.mailtrap_settings = {
  api_key: ENV.fetch('MAILTRAP_API_KEY')
}
```

### Pure Ruby

```ruby
require 'mailtrap'

# Create mail object
mail = Mailtrap::Mail.from_content(
  from: { email: 'mailtrap@example.com', name: 'Mailtrap Test' },
  to: [
    { email: 'your@email.com' }
  ],
  reply_to: { email: 'support@example.com', name: 'Mailtrap Reply-To' },
  subject: 'You are awesome!',
  text: 'Congrats for sending test email with Mailtrap!'
)

# Create client and send
client = Mailtrap::Client.new(api_key: 'your-api-key')
client.send(mail)

# You can also pass the request parameters directly
client.send(
  from: { email: 'mailtrap@example.com', name: 'Mailtrap Test' },
  to: [
    { email: 'your@email.com' }
  ],
  subject: 'You are awesome!',
  text: 'Congrats for sending test email with Mailtrap!'
)
```

### Send Email Using Template

```ruby
require 'mailtrap'

client = Mailtrap::Client.new(api_key: 'your-api-key')

mail = Mailtrap::Mail.from_template(
  from: { email: 'mailtrap@example.com', name: 'Mailtrap Test' },
  to: [
    { email: 'your@email.com' }
  ],
  template_uuid: '2f45b0aa-bbed-432f-95e4-e145e1965ba2',
  template_variables: {
    'user_name' => 'John Doe'
  }
)

client.send(mail)
```

### Email Sandbox (Testing)

```ruby
require 'mailtrap'

# Send to sandbox inbox for testing
client = Mailtrap::Client.new(
  api_key: 'your-api-key',
  sandbox: true,
  inbox_id: 12
)

client.send(
  from: { email: 'mailtrap@example.com', name: 'Mailtrap Test' },
  to: [
    { email: 'your@email.com' }
  ],
  subject: 'Test Email',
  text: 'This is a test email sent to sandbox inbox'
)
```

### Batch Sending

Send up to 500 emails in one API call:

```ruby
require 'mailtrap'

client = Mailtrap::Client.new(api_key: 'your-api-key')

batch_base = Mailtrap::Mail.batch_base_from_content(
  from: { email: 'mailtrap@demomailtrap.co', name: 'Mailtrap Test' },
  subject: 'You are awesome!',
  text: 'Congrats for sending test email with Mailtrap!',
  html: '<p>Congrats for sending test email with Mailtrap!</p>'
)

client.send_batch(
  batch_base, [
    Mailtrap::Mail.from_content(
      to: [
        { email: 'john.doe@email.com', name: 'John Doe' }
      ]
    ),
    Mailtrap::Mail.from_content(
      to: [
        { email: 'jane.doe@email.com', name: 'Jane Doe' }
      ]
    )
  ]
)
```

### Email Templates API

```ruby
require 'mailtrap'

client = Mailtrap::Client.new(api_key: 'your-api-key')
templates = Mailtrap::EmailTemplatesAPI.new(3229, client)

templates.create(
  name: 'Welcome Email',
  subject: 'Welcome to Mailtrap!',
  body_html: '<h1>Hello</h1>',
  body_text: 'Hello',
  category: 'welcome'
)

# Get all templates
templates.list

# Get a specific template
templates.get(email_template.id)

# Update a template
templates.update(email_template.id, name: 'Welcome Updated')

# Delete a template
templates.delete(email_template.id)
```

### Contacts API

```ruby
require 'mailtrap'

client = Mailtrap::Client.new(api_key: 'your-api-key')
contacts = Mailtrap::ContactsAPI.new(3229, client)
contact_lists = Mailtrap::ContactListsAPI.new(3229, client)
contact_fields = Mailtrap::ContactFieldsAPI.new(3229, client)

# Create contact list
list = contact_lists.create(name: 'Test List')

# Create contact field
field = contact_fields.create(
  name: 'Nickname',
  data_type: 'text',
  merge_tag: 'nickname'
)

# Create contact
contact = contacts.create(
  email: 'test@example.com',
  fields: { field.merge_tag => 'John Doe' },
  list_ids: [list.id]
)

# Get contact
contact = contacts.get(contact.id)

# Update contact
contacts.upsert(
  contact.id,
  email: 'test2@example.com',
  fields: { field.merge_tag => 'Jane Doe' }
)

# List contacts
contacts.list

# Delete contact
contacts.delete(contact.id)
```

### Multiple Mailtrap Clients

You can configure multiple Mailtrap clients to operate simultaneously. This setup is
particularly useful when you need to send emails using both the transactional
and bulk APIs, or when using sandbox for testing:

```ruby
# config/application.rb
ActionMailer::Base.add_delivery_method :mailtrap_bulk, Mailtrap::ActionMailer::DeliveryMethod
ActionMailer::Base.add_delivery_method :mailtrap_sandbox, Mailtrap::ActionMailer::DeliveryMethod

# config/environments/production.rb
config.action_mailer.delivery_method = :mailtrap
config.action_mailer.mailtrap_settings = {
  api_key: ENV.fetch('MAILTRAP_API_KEY')
}
config.action_mailer.mailtrap_bulk_settings = {
  api_key: ENV.fetch('MAILTRAP_API_KEY'),
  bulk: true
}
config.action_mailer.mailtrap_sandbox_settings = {
  api_key: ENV.fetch('MAILTRAP_API_KEY'),
  sandbox: true,
  inbox_id: 12
}

# app/mailers/foo_mailer.rb
mail(delivery_method: :mailtrap_bulk)  # For bulk sending
mail(delivery_method: :mailtrap_sandbox)  # For sandbox testing
```

## Examples

Refer to the [`examples`](examples) folder for the source code of this and other advanced examples:

### Contacts API

* [Contacts](examples/contacts_api.rb)

### Sending API

* [Full](examples/full.rb)
* [Email template](examples/email_template.rb)
* [ActionMailer](examples/action_mailer.rb)

### Batch Sending API

* [Batch Sending](examples/batch.rb)

### Templates API

* [Email Templates API](examples/email_templates_api.rb)

### Email Sandbox (Testing) API

* [Sandbox examples in Full](examples/full.rb)

## Content-Transfer-Encoding

`mailtrap` gem uses Mailtrap API to send emails. Mailtrap API does not try to
replicate SMTP. That is why you should expect some limitations when it comes to
sending. For example, `/api/send` endpoint ignores `Content-Transfer-Encoding`
(see `headers` in the [API documentation](https://railsware.stoplight.io/docs/mailtrap-api-docs/67f1d70aeb62c-send-email)).
Meaning your recipients will receive emails only in the default encoding which
is `quoted-printable`, if you send with Mailtrap API.

For those who need to use `7bit` or any other encoding, SMTP provides
better flexibility in that regard. Go to your _Mailtrap account_ → _Email Sending_
→ _Sending Domains_ → _Your domain_ → _SMTP/API Settings_ to find the SMTP
configuration example.

## Migration guide v1 → v2

Change `Mailtrap::Sending::Client` to `Mailtrap::Client`.

If you use classes which have `Sending` namespace, remove the namespace like in the example above.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/railsware/mailtrap-ruby). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mailtrap project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).
