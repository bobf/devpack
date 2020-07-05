# frozen_string_literal: true

module Devpack
  # Loads requested gems from configuration
  class Gems
    def initialize(config)
      @config = config
    end

    def load
      return [] if @config.requested_gems.nil?

      gems, time = timed { load_devpack }
      names = gems.map(&:first)
      warn(Messages.loaded_message(@config.devpack_path, gems, time.round(2)))
      names
    end

    private

    def timed
      start = Time.now.utc
      result = yield
      [result, Time.now.utc - start]
    end

    def load_devpack
      @config.requested_gems.map { |name| load_gem(name) }.compact
    end

    def load_gem(name)
      update_load_path(name)
      [name, Kernel.require(name)]
    rescue LoadError
      warn(Messages.failure_message(name))
      nil
    end

    def warn(message)
      Kernel.warn("[devpack] #{message}")
    end

    def gem_glob
      @gem_glob ||= GemGlob.new
    end

    def update_load_path(name)
      $LOAD_PATH.concat(GemPath.new(gem_glob, name).require_paths)
    end
  end
end
