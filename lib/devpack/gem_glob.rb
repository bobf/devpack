# frozen_string_literal: true

module Devpack
  # Locates gems by searching in RubyGems' effective search path (Gem.path)
  class GemGlob
    def find(name)
      matched_paths(name)
        .sort { |a, b| version(a) <=> version(b) }
        .reverse
    end

    private

    def glob
      @glob ||= gem_paths.map { |path| Dir.glob(path.join('gems', '*')) }.flatten
    end

    # Gem.path rather than the GEM_PATH/GEM_HOME environment variables:
    # Bundler sets GEM_PATH to an empty string when BUNDLE_PATH is configured
    # (so RubyGems searches only the bundle path), which read literally is no
    # search path at all. Gem.path resolves the same variables the way
    # RubyGems does.
    def gem_paths
      Gem.path.map { |path| Pathname.new(path) }
    end

    def match?(name_with_version, basename)
      name, _, version = name_with_version.partition(':')
      return true if version.empty? && basename.rpartition('-').first == name
      return true if !version.empty? && basename == "#{name}-#{version}"

      false
    end

    def matched_paths(name)
      glob.select do |path|
        pathname = Pathname.new(path)
        next unless pathname.directory?

        basename = pathname.basename.to_s
        match?(name, basename)
      end
    end

    def version(path)
      Gem::Version.new(File.split(path).last.rpartition('-').last)
    end
  end
end
