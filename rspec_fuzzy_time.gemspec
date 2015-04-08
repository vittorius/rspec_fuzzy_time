# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec_fuzzy_time/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec_fuzzy_time"
  spec.version       = RspecFuzzyTime::VERSION
  spec.authors       = ["Victor Zagorodny"]
  spec.email         = ["post.vittorius@gmail.com"]

  spec.summary       = "RSpec transparent time-like objects comparison with configurable precision"
  spec.description   = "This gem aims to solve the problem of difference in precision between Time-like object of Ruby having minimal fraction equal to 1 nanosecond and of some databases where minimal fraction is 1 microsecond."
  spec.homepage      = "https://github.com/vittorius/rspec_fuzzy_time"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
