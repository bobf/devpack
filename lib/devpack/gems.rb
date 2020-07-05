# frozen_string_literal: true

module Devpack
  # Parses .devpack file and provides/loads a list of specified gems
  class Gems
    FILENAME = '.devpack'
    MAX_PARENTS = 100 # Avoid infinite loops (symlinks/weird file systems)

    def initialize(path)
      @load_path = $LOAD_PATH
      @path = Pathname.new(path)
    end

    def load
      path = devpack_path
      return [] if path.nil?

      gems, time = timed { load_devpack(path) }
      names = gems.map(&:first)
      warn(loaded_message(path, gems, time.round(2)))
      names
    end

    private

    def timed
      start = Time.now.utc
      result = yield
      [result, Time.now.utc - start]
    end

    def load_devpack(path)
      gem_list(path).map { |name| load_gem(name) }.compact
    end

    def devpack_path
      return default_devpack_path if File.exist?(default_devpack_path)
      return parent_devpack_path unless parent_devpack_path.nil?

      nil
    end

    def default_devpack_path
      @path.join(FILENAME)
    end

    def gem_list(path)
      File.readlines(path).map(&:chomp)
    end

    def load_gem(name)
      # TODO: Decide what to do when Bundler is not defined.
      # Do we want to support this scenario ?
      update_load_path(name) if defined?(Bundler)
      [name, Kernel.require(name)]
    rescue LoadError
      warn(failure_message(name))
      nil
    end

    def parent_devpack_path
      next_parent = @path.parent
      loop.with_index(1) do |_, index|
        break if index >= MAX_PARENTS

        next_parent = next_parent.parent
        break if next_parent == next_parent.parent

        path = next_parent.join(FILENAME)
        next unless File.exist?(path)

        return path
      end
    end

    def warn(message)
      Kernel.warn("[devpack] #{message}")
    end

    def gems_glob
      @gems_glob ||= gem_paths.map { |path| Dir.glob(path.join('gems', '*')) }.flatten
    end

    def gem_paths
      return [] unless ENV.key?('GEM_PATH')

      ENV.fetch('GEM_PATH').split(':').map { |path| Pathname.new(path) }
    end

    def path_to_gem(name)
      found = gems_glob.find do |path|
        pathname = Pathname.new(path)
        next unless pathname.directory?

        # TODO: We should allow optionally specifying a version and default to loading
        # the latest version available.
        pathname.basename.to_s.start_with?("#{name}-")
      end

      found.nil? ? nil : Pathname.new(found)
    end

    def update_load_path(name)
      path = path_to_gem(name)
      return if path.nil?

      $LOAD_PATH.concat(require_paths(path, name))
    end

    def require_paths(gem_path, name)
      gemspec_path = gem_path.join("#{name}.gemspec")
      lib_path = gem_path.join('lib')
      # REVIEW: Some gems don't have a .gemspec - need to understand how they are loaded.
      # Use `/lib` for now if it exists as this will work for vast majority of cases.
      return [lib_path] if !gemspec_path.exist? && lib_path.exist?

      gemspec = File.read(gemspec_path.to_s)
      GemSpecificationContext.class_eval(gemspec)
      full_require_paths(gem_path)
    end

    def full_require_paths(base_path)
      GemSpecificationContext.require_paths.map { |path| base_path.join(path) }
    end

    def failure_message(name)
      base = "Failed to load `#{name}`"
      install = (defined?(Bundler) ? 'bundle exec ' : '') + "gem install #{name}"
      "#{base}. Try `#{install}`"
    end

    def loaded_message(path, gems, time)
      already_loaded = gems.size - gems.reject { |_, loaded| loaded }.size
      base = "Loaded #{already_loaded} development gem(s) from '#{path}' in #{time} seconds"
      return "#{base}." if already_loaded == gems.size

      "#{base} (#{gems.size - already_loaded} gem(s) were already loaded by environment)."
    end
  end
end
