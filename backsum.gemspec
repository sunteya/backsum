# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'backsum/version'

Gem::Specification.new do |spec|
  spec.name          = "backsum"
  spec.version       = Backsum::VERSION
  spec.authors       = [ "sunteya", "jyfcrw" ]
  spec.email         = [ "sunteya@gmail.com", "jyfcrw@gmail.com" ]
  spec.description   = %q{backsum is unix base the file system backup tools, it will incremental backup remote file to local storage.}
  spec.summary       = %q{remote incremental backup tools}
  spec.homepage      = "https://github.com/sunteya/backsum"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "cocaine", "~> 0.5.2"
  spec.add_runtime_dependency "virtus", "~> 1.0.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_development_dependency "simplecov", "~> 0.7.1"
  spec.add_development_dependency "guard-rspec", "~> 4.0.3"
end
