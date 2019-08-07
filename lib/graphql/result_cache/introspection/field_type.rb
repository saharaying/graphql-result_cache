module GraphQL
  module ResultCache
    module Introspection
      class FieldType < ::GraphQL::Introspection::FieldType

        def type
          @object.metadata[:original_non_null] && !@object.type.non_null? ? @object.type.to_non_null_type : @object.type
        end

      end
    end
  end
end