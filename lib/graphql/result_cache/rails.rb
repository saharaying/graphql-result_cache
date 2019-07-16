module GraphQL
  module ResultCache
    if defined?(::Rails)
      # Railtie integration used to default {GraphQL::ResultCache.cache}
      # and {GraphQL::ResultCache.logger} when in a Rails environment.
      class Rails < ::Rails::Engine
        config.after_initialize do
          # default values for cache and logger in Rails if not set already
          GraphQL::ResultCache.cache  = ::Rails.cache unless GraphQL::ResultCache.cache
          GraphQL::ResultCache.logger = ::Rails.logger unless GraphQL::ResultCache.logger
        end
      end
    end
  end
end