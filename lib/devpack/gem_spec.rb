# frozen_string_literal: true

module Devpack
  # Locates relevant gemspec for a given gem and provides a full list of paths
  # for all `require_paths` listed in gemspec.
  class GemSpec
    def initialize(glob, name)
      @name = name
      @glob = glob
    end

    def require_paths(visited = Set.new)
      return [] unless gemspec_path&.exist? && gem_path&.exist?

      (immediate_require_paths + dependency_require_paths(visited))
        .compact.flatten.uniq
    end

    def gemspec
      @gemspec ||= Gem::Specification.load(gemspec_path.to_s)
    end

    private

    def dependency_require_paths(visited)
      dependencies.map do |dependency|
        next nil if visited.include?(dependency)

        visited << dependency
        GemSpec.new(@glob, name_with_version(dependency)).require_paths(visited)
      end
    end

    def dependencies
      gemspec.runtime_dependencies
    end

    def gem_path
      return nil if located_gem.nil?

      Pathname.new(located_gem)
    end

    def gemspec_path
      return nil if gem_path.nil?

      gem_path.join('..', '..', 'specifications', "#{gem_path.basename}.gemspec")
              .expand_path
    end

    def immediate_require_paths
      gemspec
        .require_paths
        .map { |path| gem_path.join(path).to_s }
    end

    def name_with_version(dependency)
      spec = dependency.to_spec
      "#{spec.name}:#{spec.version}"
    rescue Gem::MissingSpecError
      dependency.name
    end

    def located_gem
      @located_gem ||= @glob.find(@name)
    end
  end
end
