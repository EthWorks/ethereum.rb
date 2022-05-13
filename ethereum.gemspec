# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ethereum/version'

Gem::Specification.new do |spec|
  spec.name          = "ethereum.rb"
  spec.version       = Ethereum::VERSION
  spec.authors       = ["Marek Kirejczyk"]
  spec.email         = ["marek.kirejczyk@gmail.com"]

  spec.summary       = %q{Ruby Ethereum client using the JSON-RPC interface}
  spec.description   = %q{Ethereum.rb is Ruby Ethereum client using the JSON-RPC interface. Provides interface for sending transactions, creating and interacting with contracts as well as usefull toolkit to work with Ethereum node.}
  spec.homepage      = "https://github.com/marekkirejczyk/ethereum.rb"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "bin"]

  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "eth", "~> 0.4"
  spec.add_development_dependency "ffi", "~> 1.15"

  spec.add_dependency "activesupport", ">= 4.2"
  spec.add_dependency "keccak", "~> 1.3"
end
