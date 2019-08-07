module GraphQL
  module ResultCache
    class Field < ::GraphQL::Schema::Field
      def initialize(*args, result_cache: nil, **kwargs, &block)
        @result_cache_config = result_cache
        super(*args, **kwargs, &block)
      end

      def to_graphql
        field_defn = super # Returns a GraphQL::Field
        field_defn.metadata[:result_cache] = @result_cache_config
        field_defn.metadata[:original_non_null] = true if @result_cache_config && field_defn.type.non_null?
        field_defn
      end
    end
  end
end
