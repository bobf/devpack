# Changelog

## 0.1.0

Core functionality implemented. Load a `.devpack` configuration file from current directory or, if not present, from a parent directory. Attempt to locate and `require` all listed gems.

## 0.1.1

Use `GEM_PATH` instead of `GEM_HOME` to locate gems.

Optimise load time by searching non-recursively in `/gems` directory (for each path listed in `GEM_PATH`).

Load latest version of gem by default. Allow specifying version with rubygems syntax `example:0.1.0`.

Permit comments in config file.

Use `Gem::Specification` to load "rendered" gemspec (i.e. the file created by rubygems when the gem is installed).  This version of the gemspec will load very quickly so no need to do custom gemspec parsing any more. This also accounts for "missing" gemspecs.
