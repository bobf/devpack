# frozen_string_literal: true

module Devpack
  # Stubbed instance_eval context to evaluate a .gemspec file and extract required_paths
  # Avoids doing expensive operations (e.g. attempting to run `git ls-files`) which are
  # typically invoked when using `Gem::Specification.load`.
  class GemSpecificationContext
    def initialize(*_); end

    class << self
      attr_accessor :require_paths

      @require_paths = []

      def require(*_); end

      def __dir__
        '.'
      end

      def require_relative(*_); end
    end

    module Gem
      # Stubbed Rubygems Gem::Specification. Everything except `require_paths=` is a no-op.
      # Catches errors for missing constants and attempts to set them in the class_eval context.
      # Constants are set recursively by setting each constant to GemSpecificationContext.
      class Specification
        def initialize(*_)
          GemSpecificationContext.require_paths = []
          begin
            yield self
          rescue NameError => e
            __devpack_resolved_receiver(e).const_set(e.name, GemSpecificationContext)
            retry
          end
        end

        def require_paths=(paths)
          GemSpecificationContext.require_paths.concat(paths)
        end

        private

        def __devpack_resolved_receiver(error)
          error.receiver
        rescue ArgumentError
          GemSpecificationContext
        end

        # rubocop:disable Style/MethodMissingSuper
        def method_missing(method_name, *args)
          return self unless Kernel.respond_to?(method_name)

          Kernel.public_send(method_name, *args)
        end
        # rubocop:enable Style/MethodMissingSuper

        def respond_to_missing?(*_)
          true
        end
      end
    end
  end
end
