# frozen_string_literal: true

module Devpack
  # Provides extended syntax for gem definitions, allowing `require: false` semantics via an
  # asterisrk prefix in `.devpack` file, e.g. `*my_gem`
  class GemRef
    def self.parse(line)
      name, _, version = line.partition(':')
      no_require = name.start_with?('*')
      name = name.sub('*', '') if no_require
      new(name: name, version: version.empty? ? nil : Gem::Requirement.new(version), no_require: no_require)
    end

    def initialize(name:, version: nil, no_require: false)
      @name = name
      @version = version
      @no_require = no_require
    end

    attr_reader :name, :version

    def require?
      !@no_require
    end

    def eql?(other)
      name == other.name && version == other.version && require? == other.require?
    end

    def to_s
      "#{require? ? '*' : ''}#{@name}:#{@version}"
    end
  end
end
