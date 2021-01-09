# frozen_string_literal: true

module Devpack
  # Locates relevant gemspec for a given gem and provides a full list of paths
  # for all `require_paths` listed in gemspec.
  class GemSpec
    def initialize(glob, name, requirement)
      @name = name
      @glob = glob
      @requirement = requirement
      @dependency = Gem::Dependency.new(@name, @requirement)
    end

    def require_paths(visited = Set.new)
      raise GemNotFoundError, @requirement.nil? ? '-' : required_version if gemspec.nil?

      (immediate_require_paths + dependency_require_paths(visited)).compact.flatten.uniq
    end

    def gemspec
      @gemspec ||= gemspecs.find do |spec|
        next false if spec.nil?

        @dependency.requirement.satisfied_by?(spec.version) && compatible?(spec)
      end
    end

    private

    def compatible?(spec)
      return false if spec.nil?
      return false if incompatible_version_loaded?(spec)

      compatible_specs?(Gem.loaded_specs.values, [@dependency] + spec.runtime_dependencies)
    end

    def incompatible_version_loaded?(spec)
      matched = Gem.loaded_specs[spec.name]
      return false if matched.nil?

      matched.version != spec.version
    end

    def required_version
      @requirement.requirements.first.last.version
    end

    def compatible_specs?(specs, dependencies)
      specs.all? { |spec| compatible_dependencies?(dependencies, spec) }
    end

    def compatible_dependencies?(dependencies, spec)
      dependencies.all? { |dependency| compatible_dependency?(dependency, spec) }
    end

    def compatible_dependency?(dependency, spec)
      return false if spec.nil?
      return true unless dependency.name == spec.name

      dependency.requirement.satisfied_by?(spec.version)
    end

    def gemspecs
      @gemspecs ||= gemspec_paths.map { |path| Gem::Specification.load(path.to_s) }
    end

    def dependency_require_paths(visited)
      dependencies.map do |dependency|
        next nil if visited.include?(dependency)

        visited << dependency
        GemSpec.new(@glob, dependency.name, dependency.requirement).require_paths(visited)
      end
    end

    def dependencies
      gemspec.runtime_dependencies
    end

    def gem_paths
      return nil if candidates.empty?

      candidates.map { |candidate| Pathname.new(candidate) }
    end

    def gemspec_paths
      return [] if gem_paths.nil?

      gem_paths.map do |path|
        path.join('..', '..', 'specifications', "#{path.basename}.gemspec").expand_path
      end
    end

    def immediate_require_paths
      gemspec
        .require_paths
        .map { |path| File.join(gemspec.full_gem_path, path) }
    end

    def candidates
      @candidates ||= @glob.find(@name)
    end
  end
end
