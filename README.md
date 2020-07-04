# Devpack

Conveniently load a set of gems to tailor your development environment without modifying your application's _Gemfile_. Configurable globally or per-project.

## Installation

Add the gem to your `Gemfile`:

```ruby
group :development, :test do
  gem 'devpack', '~> 0.1.0'
end
```

And rebuild your bundle:

```bash
$ bundle install
```

## Usage

Create a file named `.devpack` in your project's directory (or any parent directory) containing a list of gems you wish to load:

```
# .devpack
awesome_print
byebug
better_errors
```

All listed gems will be automatically required.

It is recommended that the `.devpack` file is added to your `.gitignore`:

```
# .gitignore
.devpack
```

To disable _Devpack_ set the environment variable `DISABLE_DEVPACK` to any value:
```bash
DISABLE_DEVPACK=1 bundle exec ruby myapp.rb
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
