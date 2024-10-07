# This gem adds ActionMailer delivery method.
# To configure it, add following to your ActionMailer configuration
# (in Rails projects located in `config/environments/production.rb`)
config.action_mailer.delivery_method = :mailtrap

# # Customize the settings:
# config.action_mailer.mailtrap_settings = {
#   # Use custom API key (not necessary if you've set the MAILTRAP_API_KEY environment variable)
#   api_key: Rails.application.credentials.my_mailtrap_api_key!,
#   # Switch to bulk sending (@see https://help.mailtrap.io/article/113-sending-streams)
#   bulk: true,
#   # Switch to sandbox sending (@see https://help.mailtrap.io/article/109-getting-started-with-mailtrap-email-testing)
#   sandbox: true, inbox_id: 12,
# }

# Now you can use ActionMailer to deliver mail through Mailtrap.

# To add `category` and `custom_variables`, add them to the mail generation:
mail(
  to: 'your@email.com',
  subject: 'You are awesome!',
  category: 'Test category',
  custom_variables: { test_variable: 'abc' }
)
