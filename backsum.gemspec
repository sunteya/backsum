# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'backsum/version'

Gem::Specification.new do |spec|
  spec.name          = "backsum"
  spec.version       = Backsum::VERSION
  spec.authors       = ["sunteya"]
  spec.email         = ["sunteya@gmail.com"]
  spec.description   = %q{TODO: Write a gem description}
  spec.summary       = %q{TODO: Write a gem summary}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "cocaine", "~> 0.5.2"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_development_dependency "simplecov", "~> 0.7.1"
  spec.add_development_dependency "guard-rspec", "~> 4.0.3"
end
