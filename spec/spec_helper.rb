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

    auth_header = interaction.request.headers['Authorization']&.first

    if auth_header && (match = auth_header.match(/^Bearer\s+([^,\s]+)/))
      match.captures.first
    end
  end

  config.filter_sensitive_data('ACCOUNT_ID') { ENV.fetch('MAILTRAP_ACCOUNT_ID') }

  config.before_record do |interaction|
    body = JSON.parse(interaction.response.body)

    case body
    when Hash
      body["share_links"].transform_values! { |e| e.gsub(/\/share\/.+/, '/share/REDACTED') } if body.key?("share_links")
    when Array
      body.map do |item|
        item["share_links"].transform_values! { |e| e.gsub(/\/share\/.+/, '/share/REDACTED') } if item.key?("share_links")
        item
      end
    else
      # noop
    end

    interaction.response.body = body.to_json
  rescue JSON::ParserError
    # do nothing
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
