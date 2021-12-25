# frozen_string_literal: true

module Devpack
  # Locates relevant gemspec for a given gem and provides a full list of paths
  # for all `require_paths` listed in gemspec.
  class GemSpec
    attr_reader :name, :root

    def initialize(glob, name, requirement, root: nil)
      @name = name
      @glob = glob
      @requirement = requirement
      @root = root || self
      @dependency = Gem::Dependency.new(@name, @requirement)
    end

    def require_paths(visited = Set.new)
      raise GemNotFoundError, required_version if gemspec.nil?

      (immediate_require_paths + dependency_require_paths(visited)).compact.flatten.uniq
    end

    def gemspec
      @gemspec ||= gemspecs.find do |spec|
        next false if spec.nil?

        raise_incompatible(spec) unless compatible?(spec)

        @dependency.requirement.satisfied_by?(spec.version)
      end
    end

    def pretty_name
      return @name.to_s if @requirement.nil?

      "#{@name} #{@requirement}"
    end

    private

    def compatible?(spec)
      return false if spec.nil?
      return false if incompatible_version_loaded?(spec)

      compatible_specs?([@dependency] + spec.runtime_dependencies)
    end

    def incompatible_version_loaded?(spec)
      matched = Gem.loaded_specs[spec.name]
      return false if matched.nil?

      !matched.satisfies_requirement?(@dependency)
    end

    def raise_incompatible(spec)
      raise GemIncompatibilityError.new('Incompatible dependencies', incompatible_dependencies(spec))
    end

    def required_version
      compatible_spec = gemspecs.find { |spec| requirements_satisfied_by?(spec.version) }
      return @name.to_s if compatible_spec.nil? && @requirement.nil?
      return "#{@name}:#{compatible_version}" if compatible_spec.nil?

      "#{@name}:#{compatible_spec.version}"
    end

    def compatible_version
      @requirement.requirements.find { |_operator, version| @requirement.satisfied_by?(version) }.last
    end

    def requirements_satisfied_by?(version)
      @dependency.requirement.satisfied_by?(version)
    end

    def compatible_specs?(dependencies)
      Gem.loaded_specs.values.all? { |spec| compatible_dependencies?(dependencies, spec) }
    end

    def compatible_dependencies?(dependencies, spec)
      dependencies.all? { |dependency| compatible_dependency?(dependency, spec) }
    end

    def incompatible_dependencies(spec)
      dependencies = [@dependency] + spec.runtime_dependencies
      Gem.loaded_specs.map do |_name, loaded_spec|
        next nil if compatible_dependencies?(dependencies, loaded_spec)

        [@root, dependencies.reject { |dependency| compatible_dependency?(dependency, loaded_spec) }]
      end.compact
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
        GemSpec.new(@glob, dependency.name, dependency.requirement, root: @root).require_paths(visited)
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
