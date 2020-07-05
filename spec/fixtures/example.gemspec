# -*- encoding: utf-8 -*-
# stub: example 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "example".freeze
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/example/example/blob/master/CHANGELOG.md", "homepage_uri" => "https://github.com/example/example", "source_code_uri" => "https://github.com/example/example" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Example Author".freeze]
  s.date = "2020-07-04"
  s.description = "Provide a list of gems to load in your own environment".freeze
  s.email = ["author@example.com".freeze]
  s.homepage = "https://github.com/example/example".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Conveniently tailor your development environment".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<byebug>.freeze, ["~> 11.1"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.9"])
      s.add_development_dependency(%q<rspec-its>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.86.0"])
      s.add_development_dependency(%q<strong_versions>.freeze, ["~> 0.4.4"])
    else
      s.add_dependency(%q<byebug>.freeze, ["~> 11.1"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.9"])
      s.add_dependency(%q<rspec-its>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rubocop>.freeze, ["~> 0.86.0"])
      s.add_dependency(%q<strong_versions>.freeze, ["~> 0.4.4"])
    end
  else
    s.add_dependency(%q<byebug>.freeze, ["~> 11.1"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.9"])
    s.add_dependency(%q<rspec-its>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.86.0"])
    s.add_dependency(%q<strong_versions>.freeze, ["~> 0.4.4"])
  end
end
