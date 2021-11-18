module GraphQL
  module ResultCache
    class Result
      def initialize query_result
        @_result = query_result
      end

      def process!
        process_with_result_cache
      end

      private

      def process_with_result_cache
        return process_each(@_result) unless @_result.is_a?(Array)
        @_result.each { |result| process_each(result) }
      end

      def process_each result
        result_cache_config = result.query.context[:result_cache]
        result_cache_config.process(result) unless blank?(result_cache_config)
      end

      def blank? obj
        obj.respond_to?(:empty?) ? !!obj.empty? : !obj
      end
    end
  end
end