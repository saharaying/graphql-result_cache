require 'graphql/result_cache/condition'
require 'graphql/result_cache/context_config'
require 'graphql/result_cache/key'
require 'graphql/result_cache/callback'

module GraphQL
  module ResultCache
    class FieldInstrument
      def instrument _type, field
        return field unless field.metadata[:result_cache]

        cached_resolve_proc = cached_resolve(field)
        field.redefine do
          resolve(cached_resolve_proc)
          type(field.type.of_type) if !::GraphQL::ResultCache.introspection? && field.type.non_null?
        end
      end

      private

      def cached_resolve field
        old_resolve_proc = field.resolve_proc
        cache_config = field.metadata[:result_cache]
        cache_config = {} unless cache_config.is_a?(Hash)
        lambda do |obj, args, ctx|
          if Condition.new(cache_config, obj: obj, args: args, ctx: ctx).true?
            ctx[:result_cache] ||= ContextConfig.new
            cache_key = Key.new(obj: obj, args: args, ctx: ctx, key: cache_config[:key])
            after_process = Callback.new(obj: obj, args: args, ctx: ctx, value: cache_config[:after_process]) if cache_config[:after_process]
            cached = ctx[:result_cache].add context: ctx, key: cache_key.to_s, after_process: after_process
          end
          old_resolve_proc.call(obj, args, ctx) unless cached
        end
      end
    end
  end
end
