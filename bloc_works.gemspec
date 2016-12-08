# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bloc_works/version'

Gem::Specification.new do |spec|
  spec.name          = "bloc_works"
  spec.version       = BlocWorks::VERSION
  spec.authors       = ["Gahee Heo"]
  spec.email         = ["ghbooth12@gmail.com"]

  spec.summary       = %q{Learning Web Framework}
  spec.description   = %q{Rails inspired learning Web Framework}
  spec.homepage      = "https://github.com/ghbooth12/bloc_works"
  spec.license       = "MIT"

  spec.files         = `git ls-files | grep -v "\.gem$"`.split("\n").reject { |f| f.match(%r{^(test|spec|features|gem)/}) }
  # ['file1.rb', 'file2.rb']
  # [..., 'bloc_works-0.1.0.gem', ...]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rack", "~> 1.6"
  spec.add_development_dependency "erubis", "~> 2.7"
end
