module GraphQL
  module ResultCache
    module Introspection
      class FieldType < ::GraphQL::Introspection::FieldType

        def type
          return @object.type unless @object.respond_to?(:original_return_type_not_null)
          @object.original_return_type_not_null && !@object.type.non_null? ? @object.type.to_non_null_type : @object.type
        end

      end
    end
  end
end