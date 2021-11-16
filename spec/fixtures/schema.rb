class Schema < GraphQL::Schema
  query QueryType
  use GraphQL::ResultCache
end
