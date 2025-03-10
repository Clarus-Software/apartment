# frozen_string_literal: true

require 'apartment/migrator'
require 'apartment/tasks/task_helper'
require 'parallel'

apartment_namespace = namespace :apartment do
  desc 'Drop all tenants'
  task :drop do
    Apartment::TaskHelper.tenants.each do |tenant|
      puts("Dropping #{tenant} tenant")
      Apartment::Tenant.drop(tenant)
    rescue Apartment::TenantNotFound, ActiveRecord::NoDatabaseError => e
      puts e.message
    end
  end

  desc 'Migrate all tenants'
  task :migrate do
    Apartment::TaskHelper.warn_if_tenants_empty
    Apartment::TaskHelper.each_tenant do |tenant|
      Apartment::TaskHelper.migrate_tenant(tenant)
    end
  end

  desc 'Rolls the migration back to the previous version (specify steps w/ STEP=n) across all tenants.'
  task :rollback do
    Apartment::TaskHelper.warn_if_tenants_empty

    step = ENV['STEP'] ? ENV['STEP'].to_i : 1

    Apartment::TaskHelper.each_tenant do |tenant|
      puts("Rolling back #{tenant} tenant")
      Apartment::Migrator.rollback tenant, step
    rescue Apartment::TenantNotFound => e
      puts e.message
    end
  end

  namespace :migrate do
    desc 'Runs the "up" for a given migration VERSION across all tenants.'
    task :up do
      Apartment::TaskHelper.warn_if_tenants_empty

      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version

      Apartment::TaskHelper.each_tenant do |tenant|
        puts("Migrating #{tenant} tenant up")
        Apartment::Migrator.run :up, tenant, version
      rescue Apartment::TenantNotFound => e
        puts e.message
      end
    end

    desc 'Runs the "down" for a given migration VERSION across all tenants.'
    task :down do
      Apartment::TaskHelper.warn_if_tenants_empty

      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version

      Apartment::TaskHelper.each_tenant do |tenant|
        puts("Migrating #{tenant} tenant down")
        Apartment::Migrator.run :down, tenant, version
      rescue Apartment::TenantNotFound => e
        puts e.message
      end
    end

    desc 'Rolls back the tenant one migration and re migrate up (options: STEP=x, VERSION=x).'
    task :redo do
      if ENV['VERSION']
        apartment_namespace['migrate:down'].invoke
        apartment_namespace['migrate:up'].invoke
      else
        apartment_namespace['rollback'].invoke
        apartment_namespace['migrate'].invoke
      end
    end
  end
end
