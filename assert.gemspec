# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "assert/version"

Gem::Specification.new do |s|
  s.name        = "assert"
  s.version     = Assert::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kelly Redding", "Collin Redding"]
  s.email       = ["kelly@kelredd.com"]
  s.homepage    = "http://github.com/teaminsight/assert"
  s.summary     = %q{Test::Unit style testing framework, just better than Test::Unit.}
  s.description = %q{Test::Unit style testing framework, just better than Test::Unit.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency("bundler", ["~> 1.0"])
  s.add_dependency("ansi", ["~> 1.3"])
end
