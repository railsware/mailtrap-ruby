[![test](https://github.com/railsware/mailtrap-ruby/actions/workflows/main.yml/badge.svg)](https://github.com/railsware/mailtrap-ruby/actions/workflows/main.yml)

# Official Mailtrap Ruby client

This Ruby gem offers integration with the [official API](https://api-docs.mailtrap.io/) for [Mailtrap](https://mailtrap.io).

Quickly add email sending functionality to your Ruby application with Mailtrap.

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

### Minimal

```ruby
require 'mailtrap'

# create mail object
mail = Mailtrap::Sending::Mail.new(
  from: { email: 'mailtrap@example.com', name: 'Mailtrap Test' },
  to: [
    { email: 'your@email.com' }
  ],
  subject: 'You are awesome!',
  text: "Congrats for sending test email with Mailtrap!"
)

# create client and send
client = Mailtrap::Sending::Client.new(api_key: 'your-api-key')
client.send(mail)
```

### Full

```ruby
require 'mailtrap'
require 'base64'

mail = Mailtrap::Sending::Mail.new(
  from: { email: 'mailtrap@example.com', name: 'Mailtrap Test' },
  to: [
    { email: 'your@email.com', name: 'Your name' }
  ],
  cc: [
    { email: 'cc@email.com', name: 'Copy To' }
  ],
  bcc: [
    { email: 'bcc@email.com', name: 'Hidden Recipient' }
  ],
  subject: 'You are awesome!',
  text: "Congrats for sending test email with Mailtrap!",
  category: "Integration Test",
  attachments: [
    {
      content: Base64.encode64('Attachment content'), # base64 encoded content or IO string
      filename: 'attachment.txt'
    }
  ],
  headers: {
    'X-MT-Header': 'Custom header'
  },
  custom_variables: {
    year: 2022
  }
)

data = File.open('/path/to/image.jpg').read
encoded = Base64.encode64(data).gsub(/\n/,"")

mail.add_attachment(content: encoded, filename: 'image.png')

client = Mailtrap::Sending::Client.new(api_key: 'your-api-key')
client.send(mail)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/railsware/mailtrap-ruby). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mailtrap project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).
