module GraphQL
  module ResultCache
    class Result
      extend Forwardable

      def_delegators :@value, :to_h, :[], :keys, :values, :to_json, :as_json

      def initialize query_result
        @_result = query_result
        @value = process_with_result_cache
      end

      private

      def process_with_result_cache
        result_cache_config = @_result.query.context[:result_cache]
        blank?(result_cache_config) ? @_result : result_cache_config.process_result(@_result)
      end

      def blank? obj
        obj.respond_to?(:empty?) ? !!obj.empty? : !obj
      end
    end
  end
end