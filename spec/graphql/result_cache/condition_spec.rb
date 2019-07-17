require 'spec_helper'

RSpec.describe GraphQL::ResultCache::Condition do
  let(:obj) { double('obj', a: true, b: false) }
  let(:args) { double('args') }
  let(:ctx) { double('ctx') }

  it 'should returns true without if condition' do
    condition = GraphQL::ResultCache::Condition.new({}, obj: obj, args: args, ctx: ctx)
    expect(condition).to be_true
  end

  it 'should execute with symbol config' do
    condition = GraphQL::ResultCache::Condition.new({if: :a}, obj: obj, args: args, ctx: ctx)
    expect(condition).to be_true

    condition = GraphQL::ResultCache::Condition.new({if: :b}, obj: obj, args: args, ctx: ctx)
    expect(condition).not_to be_true
  end

  it 'should execute with proc config' do
    condition = GraphQL::ResultCache::Condition.new({if: ->(obj, args, ctx) { obj.a }}, obj: obj, args: args, ctx: ctx)
    expect(condition).to be_true

    condition = GraphQL::ResultCache::Condition.new({if: ->(obj, args, ctx) { obj.b }}, obj: obj, args: args, ctx: ctx)
    expect(condition).not_to be_true
  end
end
