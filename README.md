# GraphQL::ResultCache

This gem is to cache the json result, instead of resolved object.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql-result_cache'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install graphql-result_cache

## Usage

1. Use `GraphQL::ResultCache` as a plugin in your schema.
 
```ruby
class MySchema < GraphQL::Schema
  mutation Types::MutationType
  query Types::QueryType
 
  use GraphQL::ResultCache
end
```

2. Add the custom field class to accept `result_cache` metadata.

```ruby
module Types
  class BaseObject < GraphQL::Schema::Object
    field_class GraphQL::ResultCache::Field
  end
end
```

3. Config the fields which need to be cached with `result_cache` definition.

```ruby
field :theme, Types::ThemeType, null: false, result_cache: true
```

4. Wrap query result with `GraphQL::ResultCache::Result`.

```ruby
class GraphqlController < ApplicationController
  def execute
    # ...
    result = if params[:_json]
               multiple_execute(params[:_json], context: context)
             else
               execute_query(context: context)
             end
    render json: GraphQL::ResultCache::Result.new(result)
  end
end
```

## Result Cache Customization

### Cache condition

```ruby
field :theme, Types::ThemeType, null: false, result_cache: { if: :published? }
```
The `if` condition can be either a Symbol or a Proc.

### Customized cache key

By default, `GraphQL::ResultCache` will generate a cache key combining the field path, arguments and object. 
But you can customize the object clause by specify the `key` option.

```ruby
field :theme, Types::ThemeType, null: false, result_cache: { key: :theme_cache_key }
```
The `key` can be either a Symbol or a Proc.

### Callback after cached result applied

An `after_process` callback can be provided, eg. when some dynamic values need to be amended after cached result applied.

```ruby
field :theme, Types::ThemeType, null: false, result_cache: { after_process: :amend_dynamic_attributes }

def amend_dynamic_attributes(theme_node)
  theme_node.merge! used_count: object.theme.used_count
end
```

## Global Configuration

`GraphQL::ResultCache` can be configured in initializer.

```ruby
# config/initializers/graphql/result_cache.rb

GraphQL::ResultCache.configure do |config|
  config.namespace   = "GraphQL:Result"                         # Cache key namespace
  config.expires_in  = 1.hour                                   # Expire time for the cache, default to 1.hour
  config.client_hash = -> { Rails.cache.read(:deploy_version) } # GraphQL client package hash key, used in cache key generation, default to nil
  config.except = ->(ctx) { !ctx[:result_cacheable] }           # Exception rule, skip the cache while evaluated as true, default to nil
  config.cache       = Rails.cache                              # The cache object, default to Rails.cache in Rails
  config.logger      = Rails.logger                             # The Logger, default to Rails.logger in Rails
end
```

When using with introspection, you need to assign custom introspection to avoid getting the nullable type for a non-null type.
```ruby
class MySchema < GraphQL::Schema
  introspection ::GraphQL::ResultCache::Introspection
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/saharaying/graphql-result_cache. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GraphQL::ResultCache project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/saharaying/graphql-result_cache/blob/master/CODE_OF_CONDUCT.md).
