# frozen_string_literal: true

require_relative 'lib/mailtrap/version'

Gem::Specification.new do |spec|
  spec.name = 'mailtrap'
  spec.version = Mailtrap::VERSION
  spec.authors = ['Railsware Products Studio LLC']
  spec.email = ['support@mailtrap.io']

  spec.summary = 'Official mailtrap.io API client'
  spec.description = 'Official mailtrap.io API client'
  spec.homepage = 'https://github.com/railsware/mailtrap-ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/railsware/mailtrap-ruby'
  spec.metadata['changelog_uri'] = 'https://github.com/railsware/mailtrap-ruby/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(
        %r{\A(?:(?:bin|test|spec|features|examples)/|\.(?:git|github|travis|circleci)|appveyor)}
      )
    end
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'yard', '~> 0.9'
end
