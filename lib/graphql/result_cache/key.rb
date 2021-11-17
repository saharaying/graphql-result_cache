# frozen_string_literal: true

module GraphQL
  module ResultCache
    class Key
      def initialize(obj:, args:, ctx: nil, key: nil)
        @obj = obj
        @args = args
        @ctx = ctx
        @key = key
      end

      def to_s
        @to_s ||= [
            ::GraphQL::ResultCache.namespace,
            path_clause,
            args_clause,
            object_clause,
            client_hash_clause
        ].flatten.compact.join(':')
      end

      private

      def path_clause
        @ctx.namespace(:interpreter)[:current_path].join('.') unless @ctx.nil?
      end

      def args_clause
        @args.to_h.to_a.flatten
      end

      def object_clause
        case @key
          when Symbol
            @obj.public_send(@key)
          when Proc
            @key.call(@obj, @args, @ctx)
          when NilClass
            guess_id
          else
            @key
        end
      end

      def client_hash_clause
        clause = ::GraphQL::ResultCache.client_hash
        clause.is_a?(Proc) ? clause.call : clause
      end

      def guess_id
        object = @obj.object
        return unless object
        return object.cache_key if object.respond_to?(:cache_key)
        return object.id if object.respond_to?(:id)
        object.object_id
      end
    end
  end
end
