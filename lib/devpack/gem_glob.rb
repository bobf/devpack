# frozen_string_literal: true

module Devpack
  # Locates gems by searching in paths listed in GEM_PATH
  class GemGlob
    def find(name)
      glob.select do |path|
        pathname = Pathname.new(path)
        next unless pathname.directory?

        basename = pathname.basename.to_s
        match?(name, basename)
      end.max # FIXME: Quick-and-dirty way to get latest version - will have many edge cases.
    end

    private

    def glob
      @glob ||= gem_paths.map { |path| Dir.glob(path.join('gems', '*')) }.flatten
    end

    def gem_paths
      return [] unless ENV.key?('GEM_PATH')

      ENV.fetch('GEM_PATH').split(':').map { |path| Pathname.new(path) }
    end

    def match?(name_with_version, basename)
      name, _, version = name_with_version.partition(':')
      return true if version.empty? && basename.start_with?("#{name}-")
      return true if !version.empty? && basename == "#{name}-#{version}"

      false
    end
  end
end
