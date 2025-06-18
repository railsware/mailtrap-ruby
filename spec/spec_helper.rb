# frozen_string_literal: true

require 'mail'
require 'mailtrap'
require 'rspec/its'
require 'webmock/rspec'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.filter_sensitive_data('<BEARER_TOKEN>') do |interaction|
    next if interaction.request.uri =~ /localhost/

    interaction.request.uri.gsub!(%r{/accounts/\d+/}, '/accounts/1111111/')
    interaction.response.body.gsub!(/"account_id":\d+/, '"account_id": 1111111')

    auth_header = interaction.request.headers['Authorization']&.first

    if auth_header && (match = auth_header.match(/^Bearer\s+([^,\s]+)/))
      match.captures.first
    end
  end

  header_matcher = lambda do |request_1, request_2|
    headers_1, headers_2 = [request_1, request_2].map do |req|
      req.headers.slice('Accept-Encoding', 'User-Agent', 'Content-Type')
    end

    headers_1 == headers_2
  end

  config.default_cassette_options = {
    match_requests_on: [:method, :uri, :body, header_matcher],
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

# Custom matcher to verify object IDs are different
RSpec::Matchers.define :have_different_object_id_than do |expected|
  match do |actual|
    actual.object_id != expected.object_id
  end

  failure_message do |actual|
    "expected #{actual.inspect} (object_id: #{actual.object_id}) to have a different object_id than #{expected.inspect} (object_id: #{expected.object_id})" # rubocop:disable Layout/LineLength
  end

  failure_message_when_negated do |actual|
    "expected #{actual.inspect} (object_id: #{actual.object_id}) to have the same object_id as #{expected.inspect} (object_id: #{expected.object_id})" # rubocop:disable Layout/LineLength
  end
end
