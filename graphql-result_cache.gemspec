
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphql/result_cache/version'

Gem::Specification.new do |spec|
  spec.name          = 'graphql-result_cache'
  spec.version       = GraphQL::ResultCache::VERSION
  spec.authors       = ['Ying Fu']
  spec.email         = ['saharaying@gmail.com']

  spec.summary       = 'A result caching plugin for graphql-ruby'
  spec.description   = 'A result caching plugin for graphql-ruby'
  spec.homepage      = 'https://github.com/saharaying/graphql-result_cache'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency 'graphql', '~> 1.9'

  spec.required_ruby_version = '>= 2.1.0'
end
