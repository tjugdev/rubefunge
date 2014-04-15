# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubefunge/version'

Gem::Specification.new do |spec|
  spec.name          = "rubefunge"
  spec.version       = Rubefunge::VERSION
  spec.authors       = ["Tristan Jugdev"]
  spec.summary       = %q{An interpreter for Befunge}
  spec.description   = %q{A Befunge-93 compliant interpreter and debugger}
  spec.homepage      = "https://github.com/tjugdev/rubefunge"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   << "rubefunge"
  spec.test_files    = Dir.glob("test/test_*.rb")
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
