# frozen_string_literal: true

#   Some shared contexts for specs

shared_context 'with default schema', default_tenant: true do
  let(:default_tenant) { Apartment::Test.next_db }

  before do
    Apartment::Test.create_schema(default_tenant)
    Apartment.default_tenant = default_tenant
  end

  after do
    # resetting default_tenant so we can drop and any further resets won't try to access droppped schema
    Apartment.default_tenant = nil
    Apartment::Test.drop_schema(default_tenant)
  end
end

# Some default setup for elevator specs
shared_context 'elevators', elevator: true do
  let(:company1)  { mock_model(Company, database: db1).as_null_object }
  let(:company2)  { mock_model(Company, database: db2).as_null_object }

  let(:api)       { Apartment::Tenant }

  before do
    Apartment.reset # reset all config
    api.reload!(config)
    api.create(db1)
    api.create(db2)
  end

  after do
    api.drop(db1)
    api.drop(db2)
  end
end

shared_context 'persistent_schemas', persistent_schemas: true do
  let(:persistent_schemas) { %w[hstore postgis] }

  before do
    persistent_schemas.map { |schema| subject.create(schema) }
    Apartment.persistent_schemas = persistent_schemas
  end

  after do
    Apartment.persistent_schemas = []
    persistent_schemas.map { |schema| subject.drop(schema) }
  end
end
