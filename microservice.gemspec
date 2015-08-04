# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'microservice/version'

Gem::Specification.new do |spec|

  spec.name           = "microservice"
  spec.version        = Microservice::VERSION
  spec.summary        = 'Blinker Microservice Platform'
  spec.description    = 'A Sinatra-based platform for Blinker microservices, which will provide the foundation for Recognize 2.0 and Gateway 2.0.'
  spec.homepage       = 'https://github.com/BlinkerGit/microservice'
  spec.authors        = ["Andy Rusterholz"]
  spec.email          = ["andy@blinker.com"]
  spec.license        = 'MIT'

  spec.files          = `git ls-files -z`.split("\x0").reject{ |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths  = %w(lib)

  spec.add_dependency 'activesupport-json_encoder', '~> 1.1'
  spec.add_dependency 'envied',                     '~> 0.8'
  spec.add_dependency 'foreman',                    '~> 0.78'
  spec.add_dependency 'nokogiri',                   '~> 1.6'
  spec.add_dependency 'puma',                       '~> 2.12'
  spec.add_dependency 'rest-client',                '~> 1.8.0'
  # spec.add_dependency 'savon',                    '~> 2.10.0' # This will be relevant when SOAP is implemented.
  spec.add_dependency 'sinatra',                    '~> 1.4'
  spec.add_dependency 'vcr',                        '~> 2.9'
  spec.add_dependency 'virtus',                     '~> 1.0'
  spec.add_dependency 'webmock'

  spec.add_development_dependency 'bundler',        '~> 1.10'
  spec.add_development_dependency 'rake',           '~> 10.0'
  spec.add_development_dependency 'rspec',          '~> 3.3'
  spec.add_development_dependency 'fuubar'
  spec.add_development_dependency 'json_expressions'

end
