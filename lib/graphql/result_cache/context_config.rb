module GraphQL
  module ResultCache
    class ContextConfig

      attr_accessor :value

      def initialize
        @value = {}
      end

      def add context:, key:, after_process: nil
        @value[context.query] ||= []
        cached = cache.exist? key
        logger && logger.info("GraphQL result cache key #{cached ? 'hit' : 'miss'}: #{key}")
        config_value = { path: context.path, key: key }
        if cached
          config_value[:result] = cache.read(key)
          config_value[:after_process] = after_process if after_process
        end
        @value[context.query] << config_value
        cached
      end

      def process result
        config_of_query = of_query(result.query)
        blank?(config_of_query) ? result : cache_or_amend_result(result, config_of_query)
      end

      def of_query query
        @value[query]
      end

      private

      def blank? obj
        obj.respond_to?(:empty?) ? !!obj.empty? : !obj
      end

      def cache_or_amend_result result, config_of_query
        config_of_query.each do |config|
          if config[:result].nil?
            cache.write config[:key], dig(result, 'data', *config[:path]), cache_write_options.merge(expires_in: expires_in)
          else
            # result already got from cache, need to amend to response
            result_hash = result.to_h
            deep_merge! result_hash, 'data' => config[:path].reverse.inject(config[:result]) { |a, n| {n => a} }
            config[:after_process] && config[:after_process].call(dig result_hash, 'data', *config[:path])
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

      def dig hash, *path
        return if path.length.zero?
        key = path[0]
        value = hash[key]
        other_path = path[1..-1]
        if other_path.length > 0
          dig value, *other_path if value.is_a?(Hash) || value.is_a?(Array)
        else
          value
        end
      end

      def cache
        ::GraphQL::ResultCache.cache
      end

      def cache_write_options
        ::GraphQL::ResultCache.cache_write_options || {}
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