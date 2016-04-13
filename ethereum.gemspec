# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ethereum/version'

Gem::Specification.new do |spec|
  spec.name          = "ethereum"
  spec.version       = Ethereum::VERSION
  spec.authors       = ["DigixGlobal Pte Ltd (https://dgx.io)"]
  spec.email         = ["ace@dgx.io"]

  spec.summary       = %q{Ethereum libraries for Ruby}
  spec.description   = %q{Ethereum libraries for ruby programming language.}
  spec.homepage      = "https://github.com/DigixGlobal/ethereum-ruby"
  spec.license       = "GPL"

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "bin"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_dependency "activesupport"
  spec.add_dependency "sha3-pure-ruby", "0.1.1"
end
