# For some reason, 'require "migrake/version"' doesn't work in jruby (1.6.6, on
# 1.9 mode), even with RUBYOPT=-Ilib, so resorting to this hackery.
require File.expand_path("../lib/migrake/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "migrake"
  s.version     = Migrake::VERSION
  s.description = "Migrake allows you to run rake tasks that only need to be run once in a given environment each time you deploy"
  s.summary     = "Migrake is like ActiveRecord::Migration for Rake"
  s.authors     = ["Nicolas Sanguinetti"]
  s.email       = "hi@nicolassanguinetti.info"
  s.homepage    = "http://github.com/foca/migrake"
  s.has_rdoc    = false
  s.files       = `git ls-files`.split "\n"
  s.platform    = Gem::Platform::RUBY

  s.add_dependency("rake", ">= 0.9.2")
  s.add_development_dependency("minitest")
end
