# frozen_string_literal: true

require 'spec_helper'

describe 'query caching' do
  let(:db_names) { [db1, db2] }

  before do
    Apartment.configure do |config|
      config.excluded_models = ['Company']
      config.tenant_names = -> { Company.pluck(:database) }
    end

    Apartment::Tenant.reload!(config)

    db_names.each do |db_name|
      Apartment::Tenant.create(db_name)
      Company.create database: db_name
    end
  end

  after do
    db_names.each { |db| Apartment::Tenant.drop(db) }
    Apartment::Tenant.reset
    Company.delete_all
  end

  it 'clears the ActiveRecord::QueryCache after switching databases' do
    db_names.each do |db_name|
      Apartment::Tenant.switch! db_name
      User.create! name: db_name
    end

    ActiveRecord::Base.connection.enable_query_cache!

    Apartment::Tenant.switch! db_names.first
    expect(User.find_by(name: db_names.first).name).to eq(db_names.first)

    Apartment::Tenant.switch! db_names.last
    expect(User.find_by(name: db_names.first)).to be_nil
  end
end
