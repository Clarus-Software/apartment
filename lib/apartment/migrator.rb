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

        ActiveRecord::Base.connection.migration_context.migrate(version, &migration_scope_block)
      end
    end

    # Migrate up/down to a specific version
    def run(direction, tenant_name, version)
      Tenant.switch(tenant_name) do
        ActiveRecord::Base.connection.migration_context.run(direction, version)
      end
    end

    # rollback latest migration `step` number of times
    def rollback(tenant_name, step = 1)
      Tenant.switch(tenant_name) do
        ActiveRecord::Base.connection.migration_context.rollback(step)
      end
    end
  end
end
