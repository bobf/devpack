# frozen_string_literal: true

require_relative 'lib/devpack/version'

Gem::Specification.new do |spec|
  spec.name          = 'devpack'
  spec.version       = Devpack::VERSION
  spec.authors       = ['Bob Farrell']
  spec.email         = ['git@bob.frl']

  spec.summary       = 'Conveniently tailor your development environment'
  spec.description   = 'Allow developers to optionally include a set of development gems without adding to the Gemfile.'
  spec.homepage      = 'https://github.com/bobf/devpack'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = []
  spec.require_paths = ['lib']

  spec.add_development_dependency 'byebug', '~> 11.1'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rspec-its', '~> 1.3'
  spec.add_development_dependency 'rubocop', '~> 0.86.0'
  spec.add_development_dependency 'strong_versions', '~> 0.4.4'
end
