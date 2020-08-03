# Devpack

Include a single gem in your `Gemfile` to allow developers to optionally include their preferred set of development gems without cluttering the `Gemfile`. Configurable globally or per-project.

## Installation

Add the gem to your `Gemfile`:

```ruby
group :development, :test do
  gem 'devpack', '~> 0.2.1'
end
```

And rebuild your bundle:

```bash
$ bundle install
```

## Usage

Create a file named `.devpack` in your project's directory:

```
# .devpack
awesome_print
byebug
better_errors

# Optionally specify a version:
pry:0.13.1
```

All listed gems will be automatically required when _Devpack_ is loaded.

If your gems are not auto-loaded (e.g. by _Rails_) then you must require the gem:
```ruby
require 'devpack'
```

Any gems that fail to load (due to `LoadError`) will generate a warning.

It is recommended that `.devpack` is added to your `.gitignore`.

### Initializers

Custom initializers can be loaded by creating a directory named `.devpack_initializers` containing a set of `.rb` files.

Initializers will be loaded in alphabetical order after all gems listed in the `.devpack` configuration file have been loaded.

Initializers that fail to load (for any reason) will generate a warning.

```ruby
# .devpack_initializers/pry.rb

Pry.config.pager = false
```

#### Rails

If _Rails_ is detected then files in the `.devpack_initializers` directory will be loaded using the _Rails_ `after_initialize` hook (i.e. after all other frameworks have been initialized).

```ruby
# .devpack_initializers/bullet.rb

Bullet.enable = true
```

### Global Configuration

To configure globally simply save your `.devpack` configuration file to any parent directory of your project directory, e.g. `~/.devpack`.

This strategy also applies to `.devpack_initializers`.

### Disabling

To disable _Devpack_ set the environment variable `DEVPACK_DISABLE` to any value:
```bash
DEVPACK_DISABLE=1 bundle exec ruby myapp.rb
```

### Debugging

To see the full traceback of any errors encountered at load time set the environment variable `DEVPACK_DEBUG` to any value:
```bash
DEVPACK_DEBUG=1 bundle exec ruby myapp.rb
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
