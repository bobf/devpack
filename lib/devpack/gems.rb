# frozen_string_literal: true

module Devpack
  # Loads requested gems from configuration
  class Gems
    include Timeable

    def initialize(config, glob = GemGlob.new)
      @config = config
      @gem_glob = glob
      @failures = []
      @missing = []
    end

    def load
      return [] if @config.requested_gems.nil?

      gems, time = timed { load_devpack }
      names = gems.map(&:first)
      summarize(gems, time)
      names
    end

    private

    def summarize(gems, time)
      @failures.each do |failure|
        warn(:error, Messages.failure(failure[:name], failure[:message]))
      end
      warn(:success, Messages.loaded(@config.devpack_path, gems, time.round(2)))
      warn(:info, Messages.install_missing(@missing)) unless @missing.empty?
    end

    def load_devpack
      @config.requested_gems.map do |requested|
        name, _, version = requested.partition(':')
        load_gem(name, version.empty? ? nil : Gem::Requirement.new("= #{version}"))
      end.compact
    end

    def load_gem(name, requirement)
      [name, activate(name, requirement)]
    rescue LoadError => e
      deactivate(name)
      @failures << { name: name, message: load_error_message(e) }
      nil
    rescue GemNotFoundError => e
      @missing << { name: name, version: e.message == '-' ? nil : e.message }
      nil
    end

    def activate(name, version)
      spec = GemSpec.new(@gem_glob, name, version)
      update_load_path(spec.require_paths)
      # NOTE: do this before we require, because some gems use the gemspec to
      # declare their version...
      Gem.loaded_specs[name] = spec.gemspec
      loaded = Kernel.require(name)
      spec.gemspec&.activated = true
      spec.gemspec&.instance_variable_set(:@loaded, true)
      loaded
    end

    def deactivate(name)
      Gem.loaded_specs.delete(name)
    end

    def warn(level, message)
      Devpack.warn(level, message)
    end

    def load_error_message(error)
      return "(#{error.message})" unless Devpack.debug?

      %[(#{error.message})\n#{error.backtrace.join("\n")}]
    end

    def update_load_path(paths)
      $LOAD_PATH.concat(paths)
    end
  end
end
