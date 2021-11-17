class FormType < GraphQL::Schema::Object
  field_class GraphQL::ResultCache::Field

  field :setting, FormSettingType, null: true
  field :state, String, null: false, result_cache: true
end