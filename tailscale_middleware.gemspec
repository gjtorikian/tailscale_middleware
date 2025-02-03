# frozen_string_literal: true

require_relative "lib/tailscale_middleware/version"

Gem::Specification.new do |spec|
  spec.name = "tailscale_middleware"
  spec.version = TailscaleMiddleware::VERSION
  spec.authors = ["Garen J. Torikian"]
  spec.email = ["gjtorikian@users.noreply.github.com"]

  spec.summary = "Protect your routes behind Tailscale authentication."
  spec.description = "This gem uses a connection via tsclient to the Tailscale network to authenticate clients and protect your routes."
  spec.homepage = "https://github.com/gjtorikian/tailscale_middleware"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(["git", "ls-files", "-z"], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?("bin/", "test/", "spec/", "features/", ".git", ".github", "appveyor", "Gemfile")
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem

  spec.add_dependency("values", "~> 1.8")
end
