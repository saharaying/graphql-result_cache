class QueryType < GraphQL::Schema::Object
  field_class GraphQL::ResultCache::Field

  field :colors, [String], null: false, result_cache: true

  def colors
    %w[red yellow blue]
  end
end
