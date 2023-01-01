# frozen_string_literal: true

Gem.module_eval do
  def self.devpack_bin_path(gem_name, command, _version = nil)
    File.join(Gem.loaded_specs[gem_name].full_gem_path, Gem.loaded_specs[gem_name].bindir, command)
  end

  class << self
    alias_method :_orig_activate_bin_path, :activate_bin_path
    alias_method :_orig_bin_path, :bin_path

    def activate_bin_path(*args)
      _orig_activate_bin_path(*args)
    rescue Gem::Exception
      devpack_bin_path(*args)
    end

    def bin_path(*args)
      _orig_bin_path(*args)
    rescue Gem::Exception
      devpack_bin_path(*args)
    end
  end
end

def devpack_exec(args)
  options = Bundler::Thor::CoreExt::HashWithIndifferentAccess.new({ 'keep_file_descriptors' => true })
  Bundler::CLI::Exec.new(options, args).run
end

devpack_exec(ARGV[1..-1])
