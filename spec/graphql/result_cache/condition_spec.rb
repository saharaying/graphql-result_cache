require 'spec_helper'

RSpec.describe GraphQL::ResultCache::Condition do
  let(:obj) { double('obj', a: true, b: false) }
  let(:args) { double('args') }
  let(:ctx) { double('ctx') }

  context 'without global except' do
    it 'should returns true without if condition' do
      condition = GraphQL::ResultCache::Condition.new({}, obj: obj, args: args, ctx: ctx)
      expect(condition).to be_true
    end

    it 'should execute with symbol config' do
      condition = GraphQL::ResultCache::Condition.new({ if: :a }, obj: obj, args: args, ctx: ctx)
      expect(condition).to be_true

      condition = GraphQL::ResultCache::Condition.new({ if: :b }, obj: obj, args: args, ctx: ctx)
      expect(condition).not_to be_true
    end

    it 'should execute with proc config' do
      condition = GraphQL::ResultCache::Condition.new({ if: ->(obj, args, ctx) { obj.a } }, obj: obj, args: args, ctx: ctx)
      expect(condition).to be_true

      condition = GraphQL::ResultCache::Condition.new({ if: ->(obj, args, ctx) { obj.b } }, obj: obj, args: args, ctx: ctx)
      expect(condition).not_to be_true
    end
  end

  context 'with global except' do
    context 'as proc' do
      before do
        allow(::GraphQL::ResultCache).to receive(:except).and_return ->(ctx) { !ctx[:result_cacheable] }
      end

      context 'evaluated as true' do
        before(:each) do
          allow(ctx).to receive(:[]).with(:result_cacheable).and_return false
        end

        it 'should returns false without if condition' do
          condition = GraphQL::ResultCache::Condition.new({}, obj: obj, args: args, ctx: ctx)
          expect(condition).not_to be_true
        end

        it 'should returns false ignoring if condition' do
          condition = GraphQL::ResultCache::Condition.new({ if: :a }, obj: obj, args: args, ctx: ctx)
          expect(condition).not_to be_true
        end
      end

      context 'evaluated as false' do
        before(:each) do
          allow(ctx).to receive(:[]).with(:result_cacheable).and_return true
        end

        it 'should returns true without if condition' do
          condition = GraphQL::ResultCache::Condition.new({}, obj: obj, args: args, ctx: ctx)
          expect(condition).to be_true
        end

        it 'should combine with if condition' do
          condition = GraphQL::ResultCache::Condition.new({ if: :a }, obj: obj, args: args, ctx: ctx)
          expect(condition).to be_true

          condition = GraphQL::ResultCache::Condition.new({ if: :b }, obj: obj, args: args, ctx: ctx)
          expect(condition).not_to be_true
        end
      end
    end
  end
end
