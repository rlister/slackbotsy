# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slackbotsy/version'

Gem::Specification.new do |spec|
  spec.name          = "slackbotsy"
  spec.version       = Slackbotsy::VERSION
  spec.authors       = ["Richard Lister"]
  spec.email         = ["rlister@gmail.com"]
  spec.description   = %q{Ruby bot for Slack chat.}
  spec.summary       = %q{Ruby bot for Slack chat.}
  spec.homepage      = "https://github.com/rlister/slackbotsy"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency 'json'
  spec.add_dependency 'sinatra'
end
