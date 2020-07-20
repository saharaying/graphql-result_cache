module GraphQL
  module ResultCache
    class Callback
      def initialize(obj:, args:, ctx:, value:, field: nil)
        @obj = obj
        @args = args
        @ctx = ctx
        @value = value
        @field = field
      end

      def call(result_hash)
        case @value
          when Symbol
            @obj.public_send(@value, result_hash)
          when Proc
            @value.call(result_hash, @obj, @args, @ctx)
        end
        ::GraphQL::ResultCache.logger && ::GraphQL::ResultCache.logger.debug("GraphQL result cache callback called for #{callback_caller}")
      end

      private

      def callback_caller
        ctx_path || @field.name
      end

      def ctx_path
        @ctx.path.empty? ? nil : @ctx.path.join('.')
      end
    end
  end
end
