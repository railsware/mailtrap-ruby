[![test](https://github.com/railsware/mailtrap-ruby/actions/workflows/main.yml/badge.svg)](https://github.com/railsware/mailtrap-ruby/actions/workflows/main.yml)
[![docs](https://shields.io/badge/docs-rubydoc.info-blue)](https://rubydoc.info/gems/mailtrap)
[![gem](https://shields.io/gem/v/mailtrap)](https://rubygems.org/gems/mailtrap)
[![downloads](https://shields.io/gem/dt/mailtrap)](https://rubygems.org/gems/mailtrap)



# Official Mailtrap Ruby client

This Ruby gem offers integration with the [official API](https://api-docs.mailtrap.io/) for [Mailtrap](https://mailtrap.io).

Quickly add email sending functionality to your Ruby application with Mailtrap.

(This client uses API v2, for v1 refer to [this documentation](https://mailtrap.docs.apiary.io/))

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

### Ruby on Rails

```ruby
# place this code in config/environments/production.rb:
config.action_mailer.delivery_method = :mailtrap

# then set the MAILTRAP_API_KEY environment variable
# using your hosting solution.
```

### Pure Ruby

```ruby
require 'mailtrap'

# create mail object
mail = Mailtrap::Mail::Base.new(
  from: { email: 'mailtrap@example.com', name: 'Mailtrap Test' },
  to: [
    { email: 'your@email.com' }
  ],
  reply_to: { email: 'support@example.com', name: 'Mailtrap Reply-To' },
  subject: 'You are awesome!',
  text: "Congrats for sending test email with Mailtrap!"
)

# create client and send
client = Mailtrap::Client.new(api_key: 'your-api-key')
client.send(mail)
```

Refer to the [`examples`](examples) folder for more examples.

- [Full](examples/full.rb)
- [Email template](examples/email_template.rb)
- [ActionMailer](examples/action_mailer.rb)

### Content-Transfer-Encoding

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

### Multiple Mailtrap Clients

You can configure two Mailtrap clients to operate simultaneously. This setup is
particularly useful when you need to send emails using both the transactional
and bulk APIs. Refer to the configuration example below:

```ruby
# config/application.rb
ActionMailer::Base.add_delivery_method :mailtrap_bulk, Mailtrap::ActionMailer::DeliveryMethod

# config/environments/production.rb
config.action_mailer.delivery_method = :mailtrap
config.action_mailer.mailtrap_settings = {
  api_key: 'your-api-key'
}
config.action_mailer.mailtrap_bulk_settings = {
  api_key: 'your-api-key',
  bulk: true
}

# app/mailers/foo_mailer.rb
mail(delivery_method: :mailtrap_bulk)
```

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
