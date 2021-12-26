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
        command = color(:cyan) { 'bundle exec devpack install' }
        "Install #{missing.size} missing gem(s): #{command} [#{color(:yellow) { missing.join(', ') }}]"
      end

      def alert_incompatible(incompatible)
        grouped_dependencies = {}
        incompatible.each do |spec, dependencies|
          key = spec.root.pretty_name
          grouped_dependencies[key] ||= []
          grouped_dependencies[key] << dependencies
        end
        alert_incompatible_message(grouped_dependencies)
      end

      def test
        puts "#{color(:green) { 'green' }} #{color(:red) { 'red' }} #{color(:blue) { 'blue' }}"
        puts "#{color(:cyan) { 'cyan' }} #{color(:yellow) { 'yellow' }} #{color(:magenta) { 'magenta' }}"
      end

      def color(name)
        "#{palette.fetch(name)}#{yield}#{palette.fetch(:reset)}"
      end

      private

      def indented(message)
        message.split("\n").map { |line| "  #{line}" }.join("\n")
      end

      def command(gems)
        "bundle exec gem install #{gems.join(' ')}"
      end

      def alert_incompatible_message(grouped_dependencies)
        incompatible_dependencies = grouped_dependencies.sort.map do |name, dependencies|
          "#{color(:cyan) { name }}: "\
            "#{dependencies.flatten.map { |dependency| color(:yellow) { dependency.to_s } }.join(', ')}"
        end
        "Unable to resolve version conflicts for #{incompatible_dependencies.size} "\
          "dependencies: #{incompatible_dependencies.join(', ')}}"
      end

      def palette
        {
          reset: "\e[39m",
          red: "\e[31m",
          green: "\e[32m",
          yellow: "\e[33m",
          blue: "\e[34m",
          magenta: "\e[35m",
          cyan: "\e[36m"
        }
      end
    end
  end
end
