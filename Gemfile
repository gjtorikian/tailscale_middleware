# frozen_string_literal: true

source "https://rubygems.org"

ruby File.read(".ruby-version").strip

# Specify your gem's dependencies in tailscale_middleware.gemspec
gemspec

gem "rake"

group :debug do
  gem "awesome_print"
  gem "debug"
end

group :test do
  gem "minitest", "~> 5.6"
  gem "mocha", "~> 3.0"
  gem "minitest-focus", "~> 1.1"

  gem "webmock", "~> 3.24"
  gem "rack-test", "~> 2.2"
end

group :lint do
  gem "rubocop-standard"
end
