# frozen_string_literal: true

module Devpack
  # Generates output messages.
  class Messages
    def self.failure_message(name)
      base = "Failed to load `#{name}`"
      install = "bundle exec gem install #{name}"
      "#{base}. Try `#{install}`"
    end

    def self.loaded_message(path, gems, time)
      already_loaded = gems.size - gems.reject { |_, loaded| loaded }.size
      base = "Loaded #{already_loaded} development gem(s) from '#{path}' in #{time} seconds"
      return "#{base}." if already_loaded == gems.size

      "#{base} (#{gems.size - already_loaded} gem(s) were already loaded by environment)."
    end
  end
end
