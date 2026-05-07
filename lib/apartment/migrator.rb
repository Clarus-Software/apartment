# frozen_string_literal: true

require 'apartment/tenant'

module Apartment
  module Migrator
    extend self

    # Migrate to latest
    def migrate(tenant_name)
      Tenant.switch(tenant_name) do
        version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil

        migration_scope_block = ->(migration) { ENV['SCOPE'].blank? || (ENV['SCOPE'] == migration.scope) }

        migration_context.migrate(version, &migration_scope_block)
      end
    end

    # Migrate up/down to a specific version
    def run(direction, tenant_name, version)
      Tenant.switch(tenant_name) do
        migration_context.run(direction, version)
      end
    end

    # rollback latest migration `step` number of times
    def rollback(tenant_name, step = 1)
      Tenant.switch(tenant_name) do
        migration_context.rollback(step)
      end
    end

    private

    def migration_context
      if ActiveRecord.gem_version >= Gem::Version.new('7.2')
        ActiveRecord::Base.connection_pool.migration_context
      else
        ActiveRecord::Base.connection.migration_context
      end
    end
  end
end
