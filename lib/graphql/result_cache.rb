require 'graphql'
require 'graphql/result_cache/version'
require 'graphql/result_cache/field'
require 'graphql/result_cache/result'
require 'graphql/result_cache/field_instrument'
require 'graphql/result_cache/field_extension'
require 'graphql/result_cache/introspection'

module GraphQL
  module ResultCache
    class << self
      attr_accessor :expires_in
      attr_accessor :namespace
      attr_accessor :cache
      attr_accessor :cache_write_options
      attr_accessor :logger

      # to expire the cache when client hash changes, should be a proc. eg:
      # c.client_hash = -> { Rails.cache.read(:deploy_version) }
      attr_accessor :client_hash

      # global condition, skip the cache when the value is true, should be a proc.
      attr_accessor :except

      # ```
      # GraphQL::ResultCache.configure do |c|
      #   c.namespace = "GraphQL:Result"
      #   c.expires_in = 1.hour
      #   c.client_hash = -> { Rails.cache.read(:deploy_version) }
      # end
      # ```
      def configure
        yield self
      end
    end

    # Default configuration
    @expires_in = 3600              # 1.hour
    @namespace = 'GraphQL:Result'

    def self.use(schema_def, options: {})
      schema_def.instrument(:field, ::GraphQL::ResultCache::FieldInstrument.new)
    end
  end
end

require 'graphql/result_cache/rails' if defined?(::Rails::Engine)
