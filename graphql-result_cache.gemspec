
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphql/result_cache/version'

Gem::Specification.new do |spec|
  spec.name          = 'graphql-result_cache'
  spec.version       = GraphQL::ResultCache::VERSION
  spec.authors       = ['Ying Fu']
  spec.email         = ['saharaying@gmail.com']

  spec.summary       = 'A result caching plugin for graphql-ruby'
  spec.description   = 'This gem is to cache the json result, instead of resolved object.'
  spec.homepage      = 'https://github.com/saharaying/graphql-result_cache'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.2', '>= 2.2.10'
  spec.add_development_dependency 'rake', '~> 12.3', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.10'

  spec.add_dependency 'graphql', '~> 1.10'

  # graphql v1.9 requires ruby >= 2.2.0
  spec.required_ruby_version = '>= 2.2.0'
end
