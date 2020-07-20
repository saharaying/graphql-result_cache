require 'spec_helper'

RSpec.describe GraphQL::ResultCache::Key do
  let(:object) { double('object', a: 'object_a') }
  let(:obj) { double('obj', a: true, b: false, object: object, cache_key: 'obj_cache_key') }
  let(:args) { {x: 1, y: 's'} }
  let(:path) { %w(publishedForm form fields) }
  let(:ctx) { double('ctx', path: path) }
  let(:field) { nil }
  let(:key) { nil }

  subject do
    described_class.new(obj: obj, args: args, ctx: ctx, key: key, field: field)
  end

  it 'should include path clause' do
    expect(subject.to_s).to include('publishedForm.form.fields')
  end

  it 'should include args clause' do
    expect(subject.to_s).to include('x:1:y:s')
  end

  context 'without context' do
    let(:ctx) { nil }

    it 'should produce key' do
      expect(subject.to_s).not_to include('publishedForm.form.fields')
    end
  end

  context 'with field clause' do
    let(:ctx) { nil }
    let(:field) { double('field', name: 'publishedForm') }

    it 'should include field name' do
      expect(subject.to_s).to include('publishedForm')
    end
  end

  describe '#object_clause' do
    let(:clause) { subject.send(:object_clause) }

    context 'when key is a symbol' do
      let(:key) { :cache_key }

      it 'should call the symbol method' do
        expect(clause).to eq('obj_cache_key')
      end
    end

    context 'when key is a proc' do
      let(:key) { ->(obj, args, ctx) { "#{obj.object.a}-#{args[:x]}-#{ctx.path.join('/')}" } }

      it 'should call the proc' do
        expect(clause).to eq('object_a-1-publishedForm/form/fields')
      end
    end

    context 'when key is a string' do
      let(:key) { 'cache_key_string' }

      it 'should be the string' do
        expect(clause).to eq('cache_key_string')
      end
    end

    context 'when key is nil' do
      context 'when object is absence' do
        let(:obj) { double('obj', object: nil) }

        it 'should be nil' do
          expect(clause).to be_nil
        end
      end

      context 'when object is present' do
        it 'should return object cache key when has' do
          allow(object).to receive(:cache_key) { 'object_cache_key' }
          expect(clause).to eq 'object_cache_key'
        end

        it 'should return object id when not respond to cache_key' do
          allow(object).to receive(:id) { 'object_id' }
          expect(clause).to eq 'object_id'
        end

        it 'should return object_id otherwise' do
          expect(clause).to eq object.object_id
        end
      end
    end
  end

  describe '#client_hash_clause' do
    let(:clause) { subject.send(:client_hash_clause) }

    context 'when client hash is a proc' do
      let(:client_hash_value) { Time.now.to_i }

      it 'should call the proc' do
        allow(::GraphQL::ResultCache).to receive(:client_hash).and_return -> { client_hash_value }
        expect(clause).to eq(client_hash_value)
      end
    end

    context 'when client hash is a scala value' do
      it 'should be nil when client hash not set' do
        allow(::GraphQL::ResultCache).to receive(:client_hash).and_return nil
        expect(clause).to be_nil
      end

      it 'should be the value when client hash is a string' do
        allow(::GraphQL::ResultCache).to receive(:client_hash).and_return 'abcdef'
        expect(clause).to eq('abcdef')
      end
    end
  end
end
