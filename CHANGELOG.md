# Changelog

## 0.1.0

Core functionality implemented. Load a `.devpack` configuration file from current directory or, if not present, from a parent directory. Attempt to locate and `require` all listed gems.

## 0.1.1

Use `GEM_PATH` instead of `GEM_HOME` to locate gems.

Optimise load time by searching non-recursively in `/gems` directory (for each path listed in `GEM_PATH`).

Load latest version of gem by default. Allow specifying version with rubygems syntax `example:0.1.0`.

Permit comments in config file.

Use `Gem::Specification` to load "rendered" gemspec (i.e. the file created by rubygems when the gem is installed).  This version of the gemspec will load very quickly so no need to do custom gemspec parsing any more. This also accounts for "missing" gemspecs.

## 0.1.2

Recursively include gem dependencies in `$LOAD_PATH` rather than assuming that any dependencies are already loaded.

Include original error message when warning that a gem was unable to be loaded.

## 0.1.3

Use a more appropriate method of identifying the latest version of a gem (use `Gem::Version` to sort matched gem paths).

Fix edge case where e.g. `pry-rails-0.1.0` was matching for `pry` due to naive match logic. Split on last dash instead of first (i.e. don't assume gems will not have a dash in their name; last dash separates gem name from version in directory name).

## 0.2.0

Add support for initializers. Files located in a `.devpack_initializers` directory will be loaded after gems configured in `.devpack` have been loaded. When using _Rails_ these files will be loaded using the `after_initialize` hook. Thanks to @joshmn for this idea: https://github.com/bobf/devpack/issues/1

Show full tracebacks of load errors when `DEVPACK_DEBUG` is set in environment.

Rename `DISABLE_DEVPACK` environment variable to `DEVPACK_DISABLE` for consistency.
