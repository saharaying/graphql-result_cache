# frozen_string_literal: true

require 'graphql/result_cache/condition'
require 'graphql/result_cache/context_config'
require 'graphql/result_cache/key'
require 'graphql/result_cache/callback'

module GraphQL
  module ResultCache
    module Schema
      class FieldExtension < GraphQL::Schema::FieldExtension
        def resolve(object:, arguments:, context:)
          cache_config = options.respond_to?(:to_h) ? options.to_h : {}

          if Condition.new(cache_config, obj: object, args: arguments, ctx: context).true?
            context[:result_cache] ||= ContextConfig.new
            cached = add_to_context_result_cache(context, object, arguments, cache_config)
          end

          yield(object, arguments) unless cached
        end

        private

        def add_to_context_result_cache(context, object, arguments, cache_config)
          cache_key = key(object, arguments, context, cache_config)
          after_process = after_process(object, arguments, context, cache_config)
          context[:result_cache].add(
            query: context.query,
            path: context.namespace(:interpreter)[:current_path],
            key: cache_key.to_s,
            after_process: after_process
          )
        end

        def key(object, arguments, context, config)
          Key.new(
            obj: object,
            args: arguments,
            ctx: context,
            key: config[:key]
          )
        end

        def after_process(object, arguments, context, config)
          return unless config[:after_process]

          Callback.new(
            obj: object,
            args: arguments,
            ctx: context,
            value: config[:after_process]
          )
        end
      end
    end
  end
end
