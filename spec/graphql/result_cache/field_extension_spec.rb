require 'spec_helper'

RSpec.describe GraphQL::ResultCache::FieldExtension do
  let(:field) { instance_double('GraphQL::Schema::Field', name: 'publishedForm') }
  let(:options) { nil }
  let(:extension) { described_class.new(field: field, options: options) }

  describe '#resolve' do
    subject do
      extension.resolve(object: obj, arguments: args, context: ctx) { |obj, args| true }
    end

    let(:obj) { double('obj', object: nil) }
    let(:args) { double('args', to_h: {}) }
    let(:ctx) { instance_double('GraphQL::Context', path: path) }
    let(:path) { %w[publishedForm form fields] }
    let(:context_config) { instance_double('GraphQL::ResultCache::ContextConfig') }
    let(:cache_key) { 'GraphQL:Result:publishedForm.form.fields:publishedForm' }

    context 'when condition passed' do
      let(:cache_config) { {} }

      before do
        allow(ctx).to receive(:[]).with(:result_cacheable).and_return true

        expect(ctx).to receive(:[])
          .with(:result_cache)
          .twice
          .and_return(context_config)

        expect(GraphQL::ResultCache::Condition).to receive(:new)
          .with(cache_config, obj: obj, args: args, ctx: ctx)
          .and_call_original
      end

      it 'adds field to cache' do
        expect(context_config).to receive(:add)
          .with(context: ctx, key: cache_key, after_process: nil)

        is_expected.to be true
      end

      context 'with after process callback' do
        let(:cache_config) { options }
        let(:options) { { after_process: :foo } }
        let(:callback) { instance_double('GraphQL::ResultCache::Callback') }

        it 'adds field to cache' do
          expect(GraphQL::ResultCache::Callback).to receive(:new)
            .with(obj: obj, args: args, ctx: ctx, value: :foo, field: field)
            .and_return(callback)

          expect(context_config).to receive(:add)
            .with(context: ctx, key: cache_key, after_process: callback)

          is_expected.to be true
        end
      end
    end

    context 'when condition not passed' do
      let(:condition) do
        instance_double('GraphQL::ResultCache::Condition', true?: false)
      end

      it 'skips caching' do
        expect(GraphQL::ResultCache::Condition).to receive(:new)
          .with({}, obj: obj, args: args, ctx: ctx)
          .and_return(condition)

        is_expected.to be true
      end
    end

    context 'when cached' do
      let(:context_config) do
        instance_double('GraphQL::ResultCache::ContextConfig', add: cached_object)
      end
      let(:cached_object) { double('cached_object') }

      it 'shortcuts field execution' do
        allow(ctx).to receive(:[]).with(:result_cacheable).and_return true

        expect(ctx).to receive(:[])
          .with(:result_cache)
          .twice
          .and_return(context_config)

        expect(GraphQL::ResultCache::Condition).to receive(:new)
          .with({}, obj: obj, args: args, ctx: ctx)
          .and_call_original

        is_expected.to be nil
      end
    end
  end
end
