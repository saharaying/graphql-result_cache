require 'spec_helper'

RSpec.describe GraphQL::ResultCache::Result do
  let(:context) { instance_double('GraphQL::Context') }
  let(:query) { instance_double('GraphQL::Query', context: context) }
  let(:result) { instance_double('GraphQL::Result', query: query) }
  let(:context_config) { instance_double('GraphQL::ResultCache::ContextConfig') }

  subject { GraphQL::ResultCache::Result.new(result) }

  context 'when result is a GraphQL::Result object' do
    it 'should process the result when result_cache constructed' do
      expect(context).to receive(:[]).with(:result_cache).and_return context_config
      expect(context_config).to receive(:process).and_return 'processed_result'
      expect(subject.value).to eq 'processed_result'
    end

    it 'should just return the result when result_cache not constructed' do
      expect(context).to receive(:[]).with(:result_cache).and_return nil
      expect(subject.value).to eq result
    end
  end

  context 'when result is an array of GraphQL::Result object' do
    let(:other_result) { instance_double('GraphQL::Result', query: instance_double('GraphQL::Query', context: context)) }
    subject { GraphQL::ResultCache::Result.new([other_result, result]) }

    it 'should process as an array when result_cache constructed' do
      expect(context).to receive(:[]).with(:result_cache).twice.and_return context_config
      expect(context_config).to receive(:process).with(other_result).and_return 'other_processed_result'
      expect(context_config).to receive(:process).with(result).and_return 'processed_result'
      expect(subject.value).to eq %w(other_processed_result processed_result)
    end

    it 'should process as an array when result_cache not constructed' do
      expect(context).to receive(:[]).with(:result_cache).twice.and_return nil
      expect(subject.value).to eq [other_result, result]
    end
  end
end