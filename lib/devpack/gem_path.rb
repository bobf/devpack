# frozen_string_literal: true

module Devpack
  # Locates relevant gemspec for a given gem and provides a full list of paths
  # for all `require_paths` listed in gemspec.
  class GemPath
    def initialize(glob, name)
      @name = name
      @glob = glob
    end

    def require_paths
      return [] unless gemspec_path&.exist? && gem_path&.exist?

      Gem::Specification
        .load(gemspec_path.to_s)
        .require_paths
        .map { |path| gem_path.join(path).to_s }
    end

    private

    def gem_path
      return nil if located_gem.nil?

      Pathname.new(located_gem)
    end

    def gemspec_path
      return nil if gem_path.nil?

      gem_path.join('..', '..', 'specifications', "#{gem_path.basename}.gemspec")
              .expand_path
    end

    def located_gem
      @located_gem ||= @glob.find(@name)
    end
  end
end
