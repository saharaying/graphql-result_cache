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
        case @if
          when Symbol
            @obj.send(@if)
          when Proc
            @if.call(@obj, @args, @ctx)
          else
            true
        end
      end
    end
  end
end