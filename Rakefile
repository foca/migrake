require "rake/testtask"
require "rubygems/package_task"

gem_spec = eval(File.read("./migrake.gemspec"))
Gem::PackageTask.new(gem_spec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
end

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
  t.verbose = true
end

task default: :test
