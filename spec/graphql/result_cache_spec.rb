require 'spec_helper'

RSpec.describe GraphQL::ResultCache do
  describe '.use' do
    subject { described_class.use(schema) }

    let(:schema) { instance_double('GraphQL::Schema') }

    context 'when graphql version below 1.10' do
      before do
        stub_const('GraphQL::VERSION', '1.9.99')
      end

      it 'defines instrument on schema' do
        expect(schema).to receive(:instrument)
          .with(:field, an_instance_of(GraphQL::ResultCache::FieldInstrument))
        subject
      end
    end

    context 'when graphql version 1.10' do
      before do
        stub_const('GraphQL::VERSION', '1.10.0')
      end

      it 'raises error' do
        expect { subject }.to raise_error(
          GraphQL::ResultCache::DeprecatedError,
          'Field Instruments are no longer supported, please use Field Extensions'
        )
      end
    end

    context 'when graphql version above 1.10' do
      before do
        stub_const('GraphQL::VERSION', '1.11.0')
      end

      it 'raises error' do
        expect { subject }.to raise_error(
          GraphQL::ResultCache::DeprecatedError,
          'Field Instruments are no longer supported, please use Field Extensions'
        )
      end
    end
  end
end
