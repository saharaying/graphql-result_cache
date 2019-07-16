module GraphQL
  module ResultCache
    class ContextConfig
      def initialize
        @value = {}
      end

      def add context:, key:
        @value[context.query] ||= []
        cached_result = cache.read key
        logger.info "GraphQL result cache key #{cached_result ? 'hit' : 'miss'}: #{key}"
        @value[context.query] << { path: context.path, key: key, result: cached_result }
        cached_result.present?
      end

      def process_result result
        config_of_query = of_query(result.query)
        config_of_query.blank? ? result : cache_or_amend_result(result, config_of_query)
      end

      def of_query query
        @value[query]
      end

      private

      def cache_or_amend_result result, config_of_query
        config_of_query.each do |config|
          # result already got from cache, need to amend to response
          if config[:result]
            deep_merge! result.to_h, 'data' => config[:path].reverse.inject(config[:result]) { |a, n| {n => a} }
          else
            cache.write config[:key], result.dig('data', *config[:path]), expires_in: expires_in
          end
        end
        result
      end

      def deep_merge! hash, other_hash, &block
        hash.merge!(other_hash) do |key, this_val, other_val|
          if this_val.is_a?(Hash) && other_val.is_a?(Hash)
            deep_merge!(this_val.dup, other_val, &block)
          elsif block_given?
            block.call(key, this_val, other_val)
          else
            other_val
          end
        end
      end

      def cache
        ::GraphQL::ResultCache.cache
      end

      def logger
        ::GraphQL::ResultCache.logger
      end

      def expires_in
        ::GraphQL::ResultCache.expires_in
      end
    end
  end
end