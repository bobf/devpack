# frozen_string_literal: true

module Devpack
  # Locates and parses .devpack config file
  class Config
    FILENAME = '.devpack'
    MAX_PARENTS = 100 # Avoid infinite loops (symlinks/weird file systems)

    def initialize(pwd)
      @pwd = Pathname.new(pwd)
    end

    def requested_gems
      return nil if devpack_path.nil?

      File.readlines(devpack_path)
          .map(&filter_comments)
          .compact
    end

    def devpack_path
      @devpack_path ||= located_config_path(@pwd)
    end

    private

    def located_config_path(next_parent)
      loop.with_index(1) do |_, index|
        return nil if index > MAX_PARENTS

        path = next_parent.join(FILENAME)
        next_parent = next_parent.parent
        next unless File.exist?(path)

        return path
      end
    end

    def filter_comments
      proc do |line|
        stripped = line.strip
        next nil if stripped.empty?
        next nil if stripped.start_with?('#')

        stripped.gsub(/\s*#.*$/, '') # Remove inline comments (like this one)
      end
    end
  end
end
