.PHONY: test
test:
	bundle exec rspec
	bundle exec rubocop
	bundle exec strong_versions

.PHONY: build
build: test
	bundle exec gem build devpack.gemspec
