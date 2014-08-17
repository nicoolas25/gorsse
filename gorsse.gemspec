# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gorsse/version'

Gem::Specification.new do |spec|
  spec.name          = 'gorsse'
  spec.version       = Gorsse::VERSION
  spec.authors       = ['Nicolas ZERMATI']
  spec.email         = ['nicoolas25@gmail.com']
  spec.summary       = %q{Have nice and fast SSE capabilities with any Ruby webserver.}
  spec.homepage      = ''
  spec.license       = 'LGPL'

  # Do not include the go sources in the packaged gem
  # spec.files       = `git ls-files -z`.split("\x0")
  spec.files         = Dir['lib/**/*']
  spec.files        += Dir['spec/**/*']
  spec.files        += ['Gemfile', 'LICENCE', 'README.md']

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
