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
mail = Mailtrap::Mail::Base.new(
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

mail = Mailtrap::Mail::Base.new(
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

### Using email template

```ruby
require 'mailtrap'

# create mail object
mail = Mailtrap::Mail::FromTemplate.new(
  from: { email: 'mailtrap@example.com', name: 'Mailtrap Test' },
  to: [
    { email: 'your@email.com' }
  ],
  template_uuid: '2f45b0aa-bbed-432f-95e4-e145e1965ba2',
  template_variables: {
    'user_name' => 'John Doe'
  }
)

# create client and send
client = Mailtrap::Sending::Client.new(api_key: 'your-api-key')
client.send(mail)
```

### ActionMailer

This gem also adds ActionMailer delivery method. To configure it, add following to your ActionMailer configuration (in Rails projects located in `config/$ENVIRONMENT.rb`):
```ruby
config.action_mailer.delivery_method = :mailtrap
config.action_mailer.mailtrap_settings = {
  api_key: ENV.fetch('MAILTRAP_API_KEY')
}
```
And continue to use ActionMailer as usual.

To add `category` and `custom_variables`, add them to the mail generation:
```ruby
mail(
  to: 'your@email.com',
  subject: 'You are awesome!',
  category: 'Test category',
  custom_variables: { test_variable: 'abc' }
)
```

#### Content-Transfer-Encoding

`mailtrap` gem uses Mailtrap API to send emails. Mailtrap API does not try to
replicate SMTP. That is why you should expect some limitations when it comes to 
sending. For example, `/api/send` endpoint ignores `Content-Transfer-Encoding`
(see `headers` in the [API documentation](https://railsware.stoplight.io/docs/mailtrap-api-docs/67f1d70aeb62c-send-email)).
Meaning your recipients will receive emails only in the default encoding which 
is `quoted-printable`, if you send with Mailtrap API.

For those who does need to use `7bit` or any other encoding, SMTP provides 
better flexibility in that regard. Go to your _Mailtrap account_ → _Email Sending_ 
→ _Sending Domains_ → _Your domain_ → _SMTP/API Settings_ to find the SMTP 
configuration example.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/railsware/mailtrap-ruby). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mailtrap project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).
