require 'spec_helper'
require 'fixtures/form_setting_type'
require 'fixtures/form_type'
require 'fixtures/query_type'
require 'fixtures/schema'

RSpec.describe 'query with result cache' do
  let(:cache_store) { double('cache_store') }
  let(:result) { Schema.execute(query_string) }

  before do
    allow(GraphQL::ResultCache).to receive(:cache).and_return cache_store
  end

  context 'cache on query type' do
    let(:query_string) { 'query { colors }' }
    let(:cache_key) { 'GraphQL:Result:colors' }

    it 'query with cache missed' do
      expect(cache_store).to receive(:exist?).with(cache_key).and_return false
      expect(cache_store).not_to receive(:read)
      expect(cache_store).to receive(:write).with(cache_key, %w[red yellow blue], expires_in: 3600)
      expect(result).to eq 'data' => { 'colors' => %w[red yellow blue] }
    end

    it 'queries with cache hits' do
      expect(cache_store).to receive(:exist?).with(cache_key).and_return true
      expect(cache_store).to receive(:read).with(cache_key).and_return %w[red yellow]
      expect(cache_store).not_to receive(:write)
      expect(result).to eq 'data' => { 'colors' => %w[red yellow] }
    end
  end

  context 'cache on embedded field type' do
    let(:query_string) do
      <<-QUERY
  query {
    form {
      setting {
        locale
      }
    }
  }
      QUERY
    end
    let(:form_obj) { OpenStruct.new setting: OpenStruct.new(locale: 'en') }
    let(:cache_key) { "GraphQL:Result:form.setting.locale:#{form_obj[:setting].object_id}" }
    before do
      allow_any_instance_of(QueryType).to receive(:form).and_return form_obj
    end

    it 'query with cache missed' do
      expect(cache_store).to receive(:exist?).with(cache_key).and_return false
      expect(cache_store).not_to receive(:read)
      expect(cache_store).to receive(:write).with(cache_key, 'en', expires_in: 3600)
      expect(result).to eq 'data' => { 'form' => { 'setting' => { 'locale' => 'en' } } }
    end

    it 'queries with cache hits' do
      expect(cache_store).to receive(:exist?).with(cache_key).and_return true
      expect(cache_store).to receive(:read).with(cache_key).and_return 'zh-CN'
      expect(cache_store).not_to receive(:write)
      expect(result).to eq 'data' => { 'form' => { 'setting' => { 'locale' => 'zh-CN' } } }
    end
  end
end
