module GraphQL
  module ResultCache
    module Schema
      class Field < ::GraphQL::Schema::Field
        attr_reader :original_return_type_not_null

        def initialize(*args, result_cache: nil, **kwargs, &block)
          super(*args, **kwargs, &block)
          return unless result_cache
          unless @return_type_null
            @original_return_type_not_null = true
            @return_type_null = true
          end
          extension FieldExtension, result_cache
        end
      end
    end
  end
end
