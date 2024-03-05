# frozen_string_literal: true

module Devpack
  # Loads requested gems from configuration
  class Gems
    include Timeable

    attr_reader :missing

    def initialize(config, glob = GemGlob.new)
      @config = config
      @gem_glob = glob
      @failures = []
      @missing = []
      @incompatible = []
    end

    def load(silent: false)
      return [] if @config.requested_gems.nil?

      gems, time = timed { load_devpack }
      names = gems.map(&:first)
      summarize(gems, time) unless silent
      names
    end

    private

    def summarize(gems, time)
      @failures.each { |failure| warn(:error, Messages.failure(failure[:name], failure[:message])) }
      warn(:success, Messages.loaded(@config, gems, time.round(2)))
      warn(:info, Messages.install_missing(@missing)) unless @missing.empty?
      warn(:info, Messages.alert_incompatible(@incompatible.flatten(1))) unless @incompatible.empty?
    end

    def load_devpack
      @config.requested_gems.map do |gem|
        load_gem(gem)
      end.compact
    end

    def load_gem(gem)
      name = gem.name
      [name, activate(gem)]
    rescue LoadError => e
      deactivate(name)
      nil.tap { @failures << { name: name, message: load_error_message(e) } }
    rescue GemNotFoundError => e
      nil.tap { @missing << e.meta }
    rescue GemIncompatibilityError => e
      nil.tap { @incompatible << e.meta }
    end

    def activate(gem)
      spec = GemSpec.new(@gem_glob, gem.name, gem.version)
      update_load_path(spec.require_paths)
      # NOTE: do this before we require, because some gems use the gemspec to
      # declare their version...
      Gem.loaded_specs[gem.name] = spec.gemspec
      loaded = require_gem(gem.name) if gem.require?
      spec.gemspec&.activated = true
      spec.gemspec&.instance_variable_set(:@loaded, true)
      loaded
    end

    def require_gem(name)
      Kernel.require(name)
    rescue LoadError => e
      raise e unless name.include?('-')

      namespaced_file = name.tr('-', '/')
      Kernel.require namespaced_file
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
      ENV['RUBYLIB'] = $LOAD_PATH.join(':')
    end
  end
end
