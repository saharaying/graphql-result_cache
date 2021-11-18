require 'graphql'
require 'graphql/result_cache/version'
require 'graphql/result_cache/result'
require 'graphql/result_cache/schema/field'
require 'graphql/result_cache/schema/field_extension'
require 'graphql/result_cache/schema/query_instrument'
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

      def use(schema_def)
        return schema_def.instrument(:query, Schema::QueryInstrument) if schema_def.interpreter?
        raise 'Please use the graphql gem version >= 1.10 with GraphQL::Execution::Interpreter'
      end
    end

    # Default configuration
    @expires_in = 3600 # 1.hour
    @namespace = 'GraphQL:Result'
  end
end

GraphQL::Schema::Field.accepts_definition(:result_cache)

require 'graphql/result_cache/rails' if defined?(::Rails::Engine)
