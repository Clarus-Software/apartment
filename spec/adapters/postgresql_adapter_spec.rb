# frozen_string_literal: true

require 'spec_helper'
require 'apartment/adapters/postgresql_adapter'

describe "Apartment::Adapters::PostgresqlAdapter", database: :postgresql do
  subject { Apartment::Tenant.adapter }

  it_behaves_like 'a generic apartment adapter callbacks'

  context 'when using schemas with schema.rb' do
    # Not sure why, but somehow using let(:tenant_names) memoizes for the whole example group, not just each test
    def tenant_names
      ActiveRecord::Base.connection.execute('SELECT nspname FROM pg_namespace;').collect { |row| row['nspname'] }
    end

    let(:default_tenant) { subject.switch { ActiveRecord::Base.connection.schema_search_path.delete('"') } }

    it_behaves_like 'a generic apartment adapter'
    it_behaves_like 'a schema based apartment adapter'
  end

  after do
    Apartment::Tenant.drop('has-dashes') if Apartment.connection.schema_exists? 'has-dashes'
  end

  # Not sure why, but somehow using let(:tenant_names) memoizes for the whole example group, not just each test
  def tenant_names
    ActiveRecord::Base.connection.execute('SELECT nspname FROM pg_namespace;').collect { |row| row['nspname'] }
  end

  let(:default_tenant) { subject.switch { ActiveRecord::Base.connection.schema_search_path.delete('"') } }

  it_behaves_like 'a generic apartment adapter'
  it_behaves_like 'a schema based apartment adapter'

  it 'allows for dashes in the schema name' do
    expect { Apartment::Tenant.create('has-dashes') }.not_to raise_error
  end
end
