require 'spec_helper'
require 'fixtures/query_type'
require 'fixtures/schema'

RSpec.describe 'query with result cache' do
  let(:cache_store) { double('cache_store') }
  let(:query_string) { 'query { colors }' }
  let(:result) { GraphQL::ResultCache::Result.new(Schema.execute(query_string)).value }

  before do
    allow(GraphQL::ResultCache).to receive(:cache).and_return cache_store
  end

  it 'query with cache missed' do
    cache_key = 'GraphQL:Result:colors'
    expect(cache_store).to receive(:exist?).with(cache_key).and_return false
    expect(cache_store).not_to receive(:read)
    expect(cache_store).to receive(:write).with(cache_key, %w[red yellow blue], expires_in: 3600)
    expect(result).to eq 'data' => { 'colors' => %w[red yellow blue] }
  end

  it 'queries with cache hits' do
    cache_key = 'GraphQL:Result:colors'
    expect(cache_store).to receive(:exist?).with(cache_key).and_return true
    expect(cache_store).to receive(:read).with(cache_key).and_return %w[red yellow]
    expect(cache_store).not_to receive(:write)
    expect(result).to eq 'data' => { 'colors' => %w[red yellow] }
  end
end
