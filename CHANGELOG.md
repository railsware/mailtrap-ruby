## [2.4.0] - 2025-08-04

- Add Email Templates API
- Add Contacts API
- Add Contact Fields API
- Add Contact Lists API
- Add Batch Sending
- Deprecate `Mailtrap::Mail::FromTemplate` in favour of `Mailtrap::Mail.from_template`

## [2.3.0] - 2025-03-06

- Drop Ruby 3.0 support
- Update dependencies

## [2.2.0] - 2024-12-18

- Added `reply_to` parameter support

## [2.1.2] - 2024-12-13

- Improved handling of invalid `from`, `to`, `cc`, `bcc` headers when sending
  with Action Mailer

## [2.1.1] - 2024-12-11

- Improved handling of empty `from` header when sending with Action Mailer

## [2.1.0] - 2024-07-08

- Fixed extraneous headers added by ActionMailer #21
- Dropped Ruby 2.7 support and added test coverage for Ruby up to 3.3 #22

## [2.0.0] - 2024-03-20

- Added arguments for `Mailtrap::Client`
  - `bulk` to use Mailtrap bulk sending API
  - `sandbox` to use Mailtrap sandbox API
  - `inbox_id` required when using Mailtrap sandbox API

- Removed Sending namespace, affected classes:
  - `Mailtrap::Sending::Client` -> `Mailtrap::Client`
  - `Mailtrap::Sending::Error` -> `Mailtrap::Error`
  - `Mailtrap::Sending::AttachmentContentError` -> `Mailtrap::AttachmentContentError`
  - `Mailtrap::Sending::AuthorizationError` -> `Mailtrap::AuthorizationError`
  - `Mailtrap::Sending::MailSizeError` -> `Mailtrap::MailSizeError`
  - `Mailtrap::Sending::RateLimitError` -> `Mailtrap::RateLimitError`
  - `Mailtrap::Sending::RejectionError` -> `Mailtrap::RejectionError`

## [1.2.2] - 2023-11-01

- Improved error handling

## [1.2.1] - 2023-04-12

- Set custom user agent

## [1.2.0] - 2023-01-27

- Breaking changes:
  - move `Mailtrap::Sending::Mail` class to `Mailtrap::Mail::Base`
  - move `Mailtrap::Sending::Convert` to `Mailtrap::Mail`
- Add mail gem 2.8 support
- Add email template support

## [1.1.1] - 2022-10-14

- Fix custom port and host usage

## [1.1.0] - 2022-07-22

- Add ActionMailer support

## [1.0.1] - 2022-06-20

- Update packed files list

## [1.0.0] - 2022-06-14

- Initial release
