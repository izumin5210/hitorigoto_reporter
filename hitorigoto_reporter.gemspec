# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hitorigoto_reporter/version'

Gem::Specification.new do |spec|
  spec.name          = "hitorigoto_reporter"
  spec.version       = HitorigotoReporter::VERSION
  spec.authors       = ["izumin5210"]
  spec.email         = ["masayuki@izumin.info"]

  spec.summary       = %q{Summarize slack posts into esa.io}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/izumin5210/hitorigoto_reporter"
  spec.license       = "MIT"


  spec.files         = Dir["{lib}/**/*"] + ["LICENSE.txt", "Rakefile", "README.md"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "esa", "~> 1.5"
  spec.add_runtime_dependency "slack-api", "~> 1.2.1"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
