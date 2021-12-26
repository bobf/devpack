# Devpack

Include a single gem in your `Gemfile` to allow developers to optionally include their preferred set of development gems without cluttering the `Gemfile`. Configurable globally or per-project.

## Installation

Create a file named `.devpack` in your project's directory, or in any parent directory:

```
# .devpack
awesome_print
byebug
better_errors

# Optionally specify a version:
pry:0.13.1
```

Add _Devpack_ to any project's `Gemfile`:

```ruby
# Gemfile
group :development, :test do
  gem 'devpack', '~> 0.3.3'
end
```

Rebuild your bundle:

```bash
bundle install
```

## Usage

Load _Devpack_ (if your gems are not auto-loaded as in e.g. a _Rails_ application environment):

```ruby
require 'devpack'
```

_Devpack_ will attempt to load all configured gems immediately, providing feedback to _stderr_. All dependencies are loaded with `require` after being recursively verified for compatibily with bundled gems before loading.

It is recommended to use a [global configuration](#global-configuration).

When using a per-project configuration, `.devpack` files should be added to `.gitignore`.

### Gem Installation

A convenience command is provided to install all gems listed in `.devpack` file that are not already installed:

```ruby
bundle exec devpack install
```

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
<a name="global-configuration"></a>
To configure globally simply save your `.devpack` configuration file to any parent directory of your project directory, e.g. `~/.devpack`.

This strategy also applies to `.devpack_initializers`.

### Silencing

To prevent _Devpack_ from displaying messages on load, set the environment variable `DEVPACK_SILENT=1` to any value:
```bash
DEVPACK_SILENT=1 bundle exec ruby myapp.rb
```

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
