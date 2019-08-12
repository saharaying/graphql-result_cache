module GraphQL
  module ResultCache
    class Callback
      def initialize obj:, args:, ctx:, value:
        @obj = obj
        @args = args
        @ctx = ctx
        @value = value
      end

      def call result_hash
        case @value
          when Symbol
            @obj.public_send(@value, result_hash)
          when Proc
            @value.call(result_hash, @obj, @args, @ctx)
        end
        ::GraphQL::ResultCache.logger && ::GraphQL::ResultCache.logger.debug("GraphQL result cache callback called for #{@ctx.path.join('.')}")
      end
    end
  end
end
