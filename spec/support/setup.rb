# frozen_string_literal: true

module Apartment
  module Spec
    module Setup
      # rubocop:disable Metrics/AbcSize
      def self.included(base)
        base.instance_eval do
          let(:db1) { Apartment::Test.next_db }
          let(:db2) { Apartment::Test.next_db }
          let(:connection) { ActiveRecord::Base.connection }

          # This around ensures that we run these hooks before and after
          # any before/after hooks defined in individual tests
          # Otherwise these actually get run after test defined hooks
          around(:each) do |example|
            def config
              db = RSpec.current_example.metadata.fetch(:database, :postgresql)

              Apartment::Test.config['connections'][db.to_s].symbolize_keys
            end

            # before
            Apartment::Tenant.reload!(config)
            ActiveRecord::Base.establish_connection config

            example.run

            # after
            ActiveRecord::Base.connection_handler.clear_all_connections!

            Apartment.excluded_models.each do |model|
              klass = model.constantize

              Apartment.connection_class.remove_connection(klass)
              klass.clear_all_connections!
              klass.reset_table_name
            end
            Apartment.reset
            Apartment::Tenant.reload!
          end
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
