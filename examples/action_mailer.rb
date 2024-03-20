# This gem adds ActionMailer delivery method.
# To configure it, add following to your ActionMailer configuration
# (in Rails projects located in `config/$ENVIRONMENT.rb`)
config.action_mailer.delivery_method = :mailtrap
config.action_mailer.mailtrap_settings = {
  api_key: ENV.fetch('MAILTRAP_API_KEY')
}
# And continue to use ActionMailer as usual.

# To add `category` and `custom_variables`, add them to the mail generation:
mail(
  to: 'your@email.com',
  subject: 'You are awesome!',
  category: 'Test category',
  custom_variables: { test_variable: 'abc' }
)
