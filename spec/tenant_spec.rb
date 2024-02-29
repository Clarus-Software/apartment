# frozen_string_literal: true

require 'spec_helper'

describe Apartment::Tenant do
  context 'using postgresql', database: :postgresql do
    before do
      subject.reload!(config)
    end

    describe '#adapter' do
      it 'should load postgresql adapter' do
        expect(subject.adapter).to be_a(Apartment::Adapters::PostgresqlSchemaAdapter)
      end

      it 'raises exception with invalid adapter specified' do
        subject.reload!(config.merge(adapter: 'unknown'))

        expect do
          Apartment::Tenant.adapter
        end.to raise_error(RuntimeError)
      end

      context 'threadsafety' do
        before { subject.create db1 }

        after  { subject.drop   db1 }

        it 'has a threadsafe adapter' do
          subject.switch!(db1)
          thread = Thread.new { expect(subject.current).to eq(subject.adapter.default_tenant) }
          thread.join
          expect(subject.current).to eq(db1)
        end
      end
    end

    # TODO: above spec are also with use_schemas=true
    context 'with schemas' do
      before do
        Apartment.configure do |config|
          config.excluded_models = []
        end
        subject.create db1
      end

      after { subject.drop db1 }

      describe '#create' do
        it 'creates schema' do
          subject.switch(db1) do
            expect(User.count).to be_zero
            User.create
            expect(User.count).to eq(1)
          end
          expect(User.count).to be_zero
        end
      end

      describe '#switch!' do
        let(:x) { rand(3) }

        context 'creating models' do
          before { subject.create db2 }

          after { subject.drop db2 }

          it 'should create a model instance in the current schema' do
            subject.switch! db2
            db2_count = User.count + x.times { User.create }

            subject.switch! db1
            db_count = User.count + x.times { User.create }

            subject.switch! db2
            expect(User.count).to eq(db2_count)

            subject.switch! db1
            expect(User.count).to eq(db_count)
          end
        end

        context 'with excluded models' do
          before do
            Apartment.configure do |config|
              config.excluded_models = ['Company']
            end
            subject.init
          end

          after do
            # Apartment::Tenant.init creates per model connection.
            # Remove the connection after testing not to unintentionally keep the connection across tests.
            Apartment.excluded_models.each do |excluded_model|
              excluded_model.constantize.remove_connection
            end
          end

          it 'should create excluded models in public schema' do
            subject.reset # ensure we're on public schema
            count = Company.count + x.times { Company.create }

            subject.switch! db1
            x.times { Company.create }
            expect(Company.count).to eq(count + x)
            subject.reset
            expect(Company.count).to eq(count + x)
          end
        end
      end
    end
  end
end
