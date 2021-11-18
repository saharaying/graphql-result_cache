module GraphQL
  module ResultCache
    module Schema
      module QueryInstrument
        module_function

        def before_query(_query) end

        def after_query(query)
          GraphQL::ResultCache::Result.new(query.result).process!
        end
      end
    end
  end
end