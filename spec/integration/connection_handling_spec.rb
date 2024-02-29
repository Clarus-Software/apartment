# frozen_string_literal: true

require 'spec_helper'

describe 'connection handling monkey patch' do
  let(:db_name) { db1 }
  let(:other_db_name) { db2 }

  before do
    Apartment.configure do |config|
      config.excluded_models = ['Company']
      config.tenant_names = -> { Company.pluck(:database) }
    end

    Apartment::Tenant.reload!(config)

    Apartment::Tenant.create(db_name)
    Apartment::Tenant.create(other_db_name)
    Company.create database: db_name
    Apartment::Tenant.switch! db_name
    User.create! name: db_name
    Apartment::Tenant.switch! other_db_name
    User.create! name: other_db_name
  end

  after do
    Apartment::Tenant.drop(db_name)
    Apartment::Tenant.drop(other_db_name)
    Apartment::Tenant.reset
    Company.delete_all
  end

  let(:role) do
    ActiveRecord.writing_role
  end

  it 'switches to the previous set tenant' do
    Apartment::Tenant.switch! db_name
    ActiveRecord::Base.connected_to(role: role) do
      expect(Apartment::Tenant.current).to eq db_name
      expect(User.pluck(:name)).to eq([db_name])
      Apartment::Tenant.switch(other_db_name) do
        expect(User.pluck(:name)).to eq([other_db_name])
      end
    end
  end
end
