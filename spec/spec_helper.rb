# frozen_string_literal: true

require 'mail'
require 'mailtrap'
require 'rspec/its'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.filter_sensitive_data('<BEARER_TOKEN>') do |interaction|
    next if interaction.request.uri =~ /localhost/

    auth_header = interaction.request.headers['Authorization']&.first

    if auth_header && (match = auth_header.match(/^Bearer\s+([^,\s]+)/))
      match.captures.first
    end
  end

  config.default_cassette_options = {
    match_requests_on: %i[method uri body],
    allow_unused_http_interactions: false,
    record: :once
  }
end

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
