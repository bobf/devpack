# frozen_string_literal: true

module Devpack
  # Loads requested initializers from configuration
  class Initializers
    include Timeable

    def initialize(config)
      @config = config
    end

    def load
      initializers, time = timed { load_initializers }
      path = @config.devpack_initializers_path
      return if path.nil?

      args = path, initializers, time.round(2)
      Devpack.warn(:success, Messages.loaded_initializers(*args))
    end

    private

    def load_initializers
      @config.devpack_initializer_paths.map { |path| load_initializer(path) }
    end

    def load_initializer(path)
      require path
    rescue ScriptError, StandardError => e
      Devpack.warn(:error, Messages.initializer_failure(path, message(e)))
      nil
    end

    def message(error)
      return "(#{error.class.name} - #{error.message&.split("\n")&.first})" unless Devpack.debug?

      %[(#{error.class.name})\n#{error.message}\n#{error.backtrace.join("\n")}]
    end
  end
end
