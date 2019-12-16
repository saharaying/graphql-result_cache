module GraphQL
  module ResultCache
    class Condition
      def initialize config, obj:, args:, ctx:
        @if = config[:if]
        @obj = obj
        @args = args
        @ctx = ctx
      end

      def true?
        return false if except?
        case @if
        when Symbol
          @obj.send(@if)
        when Proc
          @if.call(@obj, @args, @ctx)
        else
          true
        end
      end

      private

      def except?
        except = ::GraphQL::ResultCache.except
        except.is_a?(Proc) ? except.call(@ctx) : except
      end
    end
  end
end