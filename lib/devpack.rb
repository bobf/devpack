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

  class GemNotFoundError < Error; end

  class << self
    def warn(level, message)
      prefixed = message.split("\n").map { |line| "#{prefix(level)} #{line}" }.join("\n")
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

    private

    def prefix(level)
      color = { success: '32', info: '36', error: '31' }.fetch(level)
      icon = { success: '✓', info: 'ℹ', error: '✗' }.fetch(level)
      "\e[34m[\e[39mdevpack\e[34m]\e[39m \e[#{color}m#{icon}\e[39m"
    end
  end
end

unless Devpack.disabled?
  require 'devpack/railtie' if Devpack.rails?

  Devpack::Gems.new(Devpack.config).load
  Devpack::Initializers.new(Devpack.config).load unless Devpack.rails?
end
