# Devpack

Include a single gem in your `Gemfile` to allow developers to optionally include their preferred set of development gems without cluttering the `Gemfile`. Configurable globally or per-project.

## Installation

Add the gem to your `Gemfile`:

```ruby
group :development, :test do
  gem 'devpack', '~> 0.1.2'
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

All listed gems will be automatically required at launch. Any gems that fail to load will generate a warning.

It is recommended that `.devpack` is added to your `.gitignore`.

### Global Configuration

To configure globally simply save your `.devpack` configuration file to any parent directory of your project directory, e.g. `~/.devpack`.

### Disabling

To disable _Devpack_ set the environment variable `DISABLE_DEVPACK` to any value:
```bash
DISABLE_DEVPACK=1 bundle exec ruby myapp.rb
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
