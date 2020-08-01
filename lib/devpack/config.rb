# frozen_string_literal: true

module Devpack
  # Locates and parses .devpack config file
  class Config
    FILENAME = '.devpack'
    INITIALIZERS_DIRECTORY_NAME = '.devpack_initializers'
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
      @devpack_path ||= located_path(@pwd, FILENAME, :file)
    end

    def devpack_initializers_path
      @devpack_initializers_path ||= located_path(@pwd, INITIALIZERS_DIRECTORY_NAME, :directory)
    end

    def devpack_initializer_paths
      devpack_initializers_path&.glob(File.join('**', '*.rb'))&.map(&:to_s)&.sort || []
    end

    private

    def located_path(next_parent, filename, type)
      loop.with_index(1) do |_, index|
        return nil if index > MAX_PARENTS

        path = next_parent.join(filename)
        next_parent = next_parent.parent
        next unless File.exist?(path) && File.public_send("#{type}?", path)

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
