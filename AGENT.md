# AGENT.md

## Commands
- `bundle exec rake` - Run all tests and linting (default task)
- `bundle exec rake spec` - Run all RSpec tests  
- `bundle exec rspec spec/path/to/spec.rb` - Run single test file
- `bundle exec rake rubocop` - Run RuboCop linter
- `bundle install` - Install dependencies
- `bin/console` - Interactive Ruby console

## Architecture
Official Mailtrap Ruby gem for transactional/bulk email sending, sandbox testing, and contact management.

**Core Components:**
- `Mailtrap::Client` - Main API client with multiple endpoints (sending, bulk, sandbox, general)
- `Mailtrap::Mail` - Factory methods for email creation (from_content, from_template, batch operations)
- `BaseAPI` module - CRUD pattern for resources (Contacts, ContactLists, ContactFields, EmailTemplates)
- ActionMailer integration via `DeliveryMethod` and `Railtie`

## Code Style (RuboCop enforced)
- Ruby 3.1+ target, single quotes for strings, double quotes in interpolation
- Line length: 120 chars, method length: 20 lines, class length: 200 lines
- Snake_case variable naming, frozen string literals (except examples/)
- No documentation requirement, trailing commas excluded in examples/
