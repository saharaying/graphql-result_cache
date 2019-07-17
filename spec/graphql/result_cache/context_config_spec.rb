require 'spec_helper'

RSpec.describe GraphQL::ResultCache::ContextConfig do
  let(:path) { %w(publishedForm form fields) }
  let(:query) { instance_double('GraphQL::Query') }
  let(:context) { instance_double('GraphQL::Context', query: query, path: path) }
  let(:result) { instance_double('GraphQL::Result', query: query) }
  let(:cache_key) { 'cache_key' }
  let(:cache) { double('cache') }

  before do
    ::GraphQL::ResultCache.cache = cache
  end

  describe '#add' do
    it 'should add with nil result when not cached' do
      expect(cache).to receive(:exist?).with(cache_key).and_return false
      expect(subject.add(context: context, key: cache_key)).to be_falsey
      expect(subject.value[query]).to eq [path: path, key: cache_key, result: nil]
    end

    it 'should add with cached result when cached' do
      expect(cache).to receive(:exist?).with(cache_key).and_return true
      allow(cache).to receive(:read).with(cache_key).and_return 'cached_result'
      expect(subject.add(context: context, key: cache_key)).to be_truthy
      expect(subject.value[query]).to eq [path: path, key: cache_key, result: 'cached_result']
    end
  end

  describe '#process' do
    context 'with result cache on query' do
      context 'without cached result' do
        it 'should write to cache' do
          subject.value[query] = [{path: path, key: cache_key, result: nil}]
          expect(result).to receive(:dig).with('data', *path).and_return 'result_on_path'
          expect(cache).to receive(:write).with(cache_key, 'result_on_path', expires_in: 3600)
          expect(subject.process(result)).to eq result
        end
      end

      context 'with cached result' do
        it 'should amend cached result to query result' do
          subject.value[query] = [{path: path, key: cache_key, result: 'result_on_path'}]
          result_value = {'data' => {'publishedForm' => {'form' => {'name' => 'Name', 'fields' => nil, 'token' => 'ABCD'}}}}
          allow(result).to receive(:to_h).and_return result_value
          expect(cache).to receive(:write).never
          expect(subject.process(result)).to eq result
          expect(result_value).to eq 'data' => {'publishedForm' => {'form' => {'name' => 'Name', 'fields' => 'result_on_path', 'token' => 'ABCD'}}}
        end
      end
    end

    context 'without result cache on query' do
      let(:other_query) { instance_double('GraphQL::Query') }
      let(:other_result) { instance_double('GraphQL::Result', query: other_query) }

      it 'should return result without process' do
        subject.value[other_query] = [{path: path, key: cache_key, result: nil}]
        expect(result).to receive(:dig).never
        expect(cache).to receive(:write).never
        expect(subject.process(result)).to eq result
      end
    end
  end
end