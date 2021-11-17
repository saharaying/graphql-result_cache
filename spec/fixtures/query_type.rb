class QueryType < GraphQL::Schema::Object
  field_class GraphQL::ResultCache::Field

  field :colors, [String], null: false, result_cache: true
  field :form, FormType, null: false

  def colors
    %w[red yellow blue]
  end

  def form
    { state: 'draft' }
  end
end
