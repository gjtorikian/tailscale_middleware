# -*- encoding: utf-8 -*-
# stub: values 1.8.0 ruby lib

Gem::Specification.new do |s|
  s.name = "values".freeze
  s.version = "1.8.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tom Crayford".freeze, "Marc Siegel".freeze]
  s.date = "2015-07-01"
  s.description = "Simple immutable value objects for ruby.\n\n    Make a new value class: Point = Value.new(:x, :y)\n    And use it:\n    p = Point.new(1,0)\n    p.x\n    => 1\n    p.y\n    => 0\n    ".freeze
  s.email = ["tcrayford@googlemail.com".freeze, "marc@usainnov.com".freeze]
  s.homepage = "http://github.com/tcrayford/values".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7".freeze)
  s.rubygems_version = "2.2.2".freeze
  s.summary = "Simple immutable value objects for ruby".freeze

  s.installed_by_version = "3.6.2".freeze

  s.specification_version = 4

  s.add_development_dependency(%q<rspec>.freeze, ["~> 2.11.0".freeze])
end
