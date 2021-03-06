# frozen_string_literal: true

module Devpack
  # Generates output messages.
  class Messages
    class << self
      def failure(name, error_message)
        base = "Failed to load `#{name}`"
        "#{base}. #{error_message}"
      end

      def initializer_failure(path, error_message)
        "Failed to load initializer `#{path}`: #{error_message}"
      end

      def loaded(path, gems, time)
        already_loaded = gems.size - gems.reject { |_, loaded| loaded }.size
        base = "Loaded #{already_loaded} development gem(s) from '#{path}' in #{time} seconds"
        return "#{base}." if already_loaded == gems.size

        "#{base} (#{gems.size - already_loaded} gem(s) were already loaded by environment)."
      end

      def loaded_initializers(path, initializers, time)
        "Loaded #{initializers.compact.size} initializer(s) from '#{path}' in #{time} seconds"
      end

      def install_missing(missing)
        gems = missing.map do |spec|
          spec[:version].nil? ? spec[:name] : "#{spec[:name]}==#{spec[:version]}"
        end

        "Install #{missing.size} missing gem(s): #{command(gems)}"
      end

      private

      def indented(message)
        message.split("\n").map { |line| "  #{line}" }.join("\n")
      end

      def command(gems)
        "bundle exec gem install #{gems.join(' ')}"
      end
    end
  end
end
