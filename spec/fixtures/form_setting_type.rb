class FormSettingType < GraphQL::Schema::Object
  field_class GraphQL::ResultCache::Schema::Field

  field :locale, String, null: false, result_cache: true
end