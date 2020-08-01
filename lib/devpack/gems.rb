# frozen_string_literal: true

module Devpack
  # Loads requested gems from configuration
  class Gems
    include Timeable

    def initialize(config)
      @config = config
    end

    def load
      return [] if @config.requested_gems.nil?

      gems, time = timed { load_devpack }
      names = gems.map(&:first)
      warn(Messages.loaded(@config.devpack_path, gems, time.round(2)))
      names
    end

    private

    def load_devpack
      @config.requested_gems.map { |name| load_gem(name) }.compact
    end

    def load_gem(name)
      update_load_path(name)
      [name, Kernel.require(name)]
    rescue LoadError => e
      warn(Messages.failure(name, load_error_message(e)))
      nil
    end

    def warn(message)
      Devpack.warn(message)
    end

    def load_error_message(error)
      return "(#{error.message})" unless Devpack.debug?

      %[(#{error.message})\n#{error.backtrace.join("\n")}]
    end

    def gem_glob
      @gem_glob ||= GemGlob.new
    end

    def update_load_path(name)
      $LOAD_PATH.concat(GemPath.new(gem_glob, name).require_paths)
    end
  end
end
