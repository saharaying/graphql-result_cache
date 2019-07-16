module GraphQL
  module ResultCache
    class Result
      extend Forwardable

      def_delegators :@value, :to_json, :as_json

      def initialize query_result
        @_result = query_result
        @value = process_with_result_cache
      end

      private

      def process_with_result_cache
        return process_each(@_result) unless @_result.is_a?(Array)
        @_result.map { |result| process_each(result) }
      end

      def process_each result
        result_cache_config = result.query.context[:result_cache]
        blank?(result_cache_config) ? result : result_cache_config.process_result(result)
      end

      def blank? obj
        obj.respond_to?(:empty?) ? !!obj.empty? : !obj
      end
    end
  end
end