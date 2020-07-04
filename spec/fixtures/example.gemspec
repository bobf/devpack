# frozen_string_literal: true

require_relative 'lib/example/version'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'example'
  spec.version       = Example::VERSION
  spec.authors       = ['Example Author']
  spec.email         = ['author@example.com']

  spec.summary       = 'Example summary'
  spec.description   = 'Example description'
  spec.homepage      = 'http://www.example.com/'
  spec.license       = 'Example License'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = []
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'example_runtime_dependency'
  spec.add_development_dependency 'example_development_dependency'
end
