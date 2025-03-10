# frozen_string_literal: true

require 'rails'
require 'apartment/tenant'

module Apartment
  class Railtie < Rails::Railtie
    #
    #   Set up our default config options
    #   Do this before the app initializers run so we don't override custom settings
    #
    config.before_initialize do
      Apartment.configure do |config|
        config.excluded_models = []
        config.tenant_names = []
      end

      ActiveRecord::Migrator.migrations_paths = Rails.application.paths['db/migrate'].to_a
    end

    #   Hook into ActionDispatch::Reloader to ensure Apartment is properly initialized
    #   Note that this doesn't entirely work as expected in Development,
    #   because this is called before classes are reloaded
    #   See the middleware/console declarations below to help with this. Hope to fix that soon.
    #
    config.to_prepare do
      next if ARGV.any? { |arg| arg =~ /\Aassets:(?:precompile|clean)\z/ }
      next if ARGV.any?('webpacker:compile')
      next if ENV['APARTMENT_DISABLE_INIT']

      begin
        Apartment.connection_class.connection_pool.with_connection do
          Apartment::Tenant.init
        end
      rescue ::ActiveRecord::NoDatabaseError
        # Since `db:create` and other tasks invoke this block from Rails 5.2.0,
        # we need to swallow the error to execute `db:create` properly.
      end
    end

    #
    #   Ensure rake tasks are loaded
    #
    rake_tasks do
      load 'tasks/apartment.rake'
      require 'apartment/tasks/enhancements' if Apartment.db_migrate_tenants
    end
  end
end
