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

  # Retains gem specification and unavailable dependencies for use in output messages.
  class GemIncompatibilityError < Error
    attr_reader :message, :meta

    def initialize(message = nil, meta = nil)
      @message = message
      @meta = meta
      super(message)
    end
  end

  class << self
    def warn(level, message)
      return if silent?

      prefixed = message.split("\n").map { |line| "#{prefix(level)} #{line}" }.join("\n")
      Kernel.warn(prefixed)
    end

    def debug?
      ENV.key?('DEVPACK_DEBUG')
    end

    def disabled?
      ENV.key?('DEVPACK_DISABLE')
    end

    def silent?
      ENV.key?('DEVPACK_SILENT')
    end

    def rails?
      defined?(Rails::Railtie)
    end

    def config
      @config ||= Devpack::Config.new(Dir.pwd)
    end

    private

    def prefix(level)
      "#{Messages.color(:blue) { '[' }}devpack#{Messages.color(:blue) { ']' }} #{icon(level)}"
    end

    def icon(level)
      {
        success: Messages.color(:green) { '✓' },
        info: Messages.color(:cyan) { 'ℹ' },
        error: Messages.color(:red) { '✗' }
      }.fetch(level)
    end
  end
end

unless Devpack.disabled?
  require 'devpack/railtie' if Devpack.rails?

  Devpack::Gems.new(Devpack.config).load
  Devpack::Initializers.new(Devpack.config).load unless Devpack.rails?
end
