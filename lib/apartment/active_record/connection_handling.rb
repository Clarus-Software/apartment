# frozen_string_literal: true

# This is monkeypatching Active Record to ensure that whenever a new connection is established to a shard
# switches to the same tenant as before the connection switching.

module ActiveRecord # :nodoc:
  module ConnectionHandling
    def connected_to_with_tenant(role: nil, shard: nil, prevent_writes: false, &blk)
      current_tenant = Apartment::Tenant.current

      connected_to_without_tenant(role: role, shard: shard, prevent_writes: prevent_writes) do
        Apartment::Tenant.switch!(current_tenant)
        yield(blk)
      end
    end

    alias connected_to_without_tenant connected_to
    alias connected_to connected_to_with_tenant
  end
end
