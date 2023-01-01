# frozen_string_literal: true

module Devpack
  # Locates gems by searching in paths listed in GEM_PATH
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

    def gem_paths
      return [] if gem_path.nil?

      gem_path.split(':').map { |path| Pathname.new(path) }
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

    def gem_path
      return ENV.fetch('GEM_PATH', nil) if ENV.key?('GEM_PATH')
      return ENV.fetch('GEM_HOME', nil) if ENV.key?('GEM_HOME')

      nil
    end
  end
end
