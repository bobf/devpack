# frozen_string_literal: true

require 'rubygems'
require 'pathname'
require 'set'

require 'devpack/timeable'
require 'devpack/config'
require 'devpack/gems'
require 'devpack/gem_glob'
require 'devpack/gem_spec'
require 'devpack/initializers'
require 'devpack/messages'
require 'devpack/version'

# Provides helper method for writing warning messages.
module Devpack
  class Error < StandardError; end

  class << self
    def warn(message)
      prefixed = message.split("\n").map { |line| "[devpack] #{line}" }.join("\n")
      Kernel.warn(prefixed)
    end

    def debug?
      ENV.key?('DEVPACK_DEBUG')
    end

    def disabled?
      ENV.key?('DEVPACK_DISABLE')
    end

    def rails?
      defined?(Rails::Railtie)
    end

    def config
      @config ||= Devpack::Config.new(Dir.pwd)
    end
  end
end

unless Devpack.disabled?
  require 'devpack/railtie' if Devpack.rails?

  Devpack::Gems.new(Devpack.config).load
  Devpack::Initializers.new(Devpack.config).load unless Devpack.rails?
end
