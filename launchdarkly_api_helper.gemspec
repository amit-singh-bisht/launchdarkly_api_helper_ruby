# frozen_string_literal: true

require_relative 'lib/launchdarkly_api_helper/version'

Gem::Specification.new do |spec|
  spec.name = 'launchdarkly_api_helper'
  spec.version = LaunchdarklyApiHelper::VERSION
  spec.authors = ['amit-singh-bisht']
  spec.email = ['bishtamitsingh98@gmail.com']

  spec.summary = 'LaunchDarklyApiHelper provides you a way to access your Launch Darkly account using API token to view, edit or delete them accordingly. https://bit.ly/ld_doc'
  spec.description = 'LaunchDarklyApiHelper provides you a way to access your Launch Darkly account using API token to view, edit or delete them accordingly. https://bit.ly/ld_doc'
  spec.homepage = 'https://github.com/amit-singh-bisht/launchdarkly_api_helper_ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.5.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/amit-singh-bisht/launchdarkly_api_helper_ruby'
  spec.metadata['changelog_uri'] = 'https://github.com/amit-singh-bisht/launchdarkly_api_helper_ruby/blob/master/README.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
