# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the official Mailtrap Ruby client gem for integrating with the [Mailtrap API](https://api-docs.mailtrap.io/). It supports transactional email sending, bulk email sending, email sandbox testing, contact management, and email template management.

## Development Commands

### Testing and Quality
- `bundle exec rake spec` - Run all RSpec tests
- `bundle exec rake rubocop` - Run RuboCop linter 
- `bundle exec rake` - Run default task (both spec and rubocop)
- `bundle exec rspec spec/path/to/spec.rb` - Run a single test file

### Development Setup
- `bundle install` - Install dependencies
- `bin/setup` - Run setup (if available)
- `bin/console` - Start interactive console

### Gem Management
- `bundle exec rake install` - Install gem locally
- `bundle exec rake release` - Release new version (updates version, creates git tag, pushes)

## Code Architecture

### Main Components

**Client Architecture (`lib/mailtrap/client.rb`)**
- `Mailtrap::Client` - Core API client with multiple host endpoints:
  - `SENDING_API_HOST` - For transactional emails
  - `BULK_SENDING_API_HOST` - For bulk email sending 
  - `SANDBOX_API_HOST` - For email testing
  - `GENERAL_API_HOST` - For account/management operations

**Mail Objects (`lib/mailtrap/mail.rb`)**
- `Mailtrap::Mail` module with factory methods:
  - `from_content()` - Create mail with custom content (subject, text, html)
  - `from_template()` - Create mail using predefined templates
  - `batch_base_from_content()` / `batch_base_from_template()` - For batch operations
  - `from_message()` - Convert from `Mail::Message` objects

**API Resources Pattern (`lib/mailtrap/base_api.rb`)**
- `BaseAPI` module provides CRUD operations pattern for API resources
- Used by: `ContactsAPI`, `ContactListsAPI`, `ContactFieldsAPI`, `EmailTemplatesAPI`
- Each API class needs: `base_path`, `supported_options`, `response_class`

**ActionMailer Integration (`lib/mailtrap/action_mailer/`)**
- `DeliveryMethod` - Rails ActionMailer delivery method
- `Railtie` - Rails integration for auto-configuration
- Supports multiple clients (transactional, bulk, sandbox) simultaneously

### Key Design Patterns

**Client Configuration**
- Clients configured with `api_key`, `bulk: true/false`, `sandbox: true/false`
- API host automatically selected based on configuration
- Sandbox mode requires `inbox_id` parameter

**Error Handling**
- Custom exceptions in `lib/mailtrap/errors.rb`:
  - `AuthorizationError` - Invalid API key
  - `RejectionError` - Server refused request  
  - `MailSizeError` - Message too large
  - `RateLimitError` - Too many requests

**Request/Response Pattern**
- All API calls return parsed JSON with symbolized keys
- Request bodies automatically converted to JSON
- Consistent error response parsing across all endpoints

## Testing

The project uses RSpec with VCR for HTTP request recording. Test files are organized under `spec/mailtrap/` mirroring the `lib/mailtrap/` structure.

**Key Testing Patterns:**
- VCR cassettes in `spec/fixtures/vcr_cassettes/`
- Shared examples in `spec/mailtrap/mail/shared.rb`
- API integration tests with mocked HTTP responses