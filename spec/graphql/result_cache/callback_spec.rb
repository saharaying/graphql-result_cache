require 'spec_helper'

RSpec.describe GraphQL::ResultCache::Callback do
  let(:field) { instance_double('GraphQL::Schema::Field', name: 'publishedForm') }
  # let(:options) { nil }

  let(:object) { double('object', a: 'object_a') }
  let(:args) { { x: 1, y: 's' } }
  let(:ctx) { instance_double('GraphQL::Context', path: %w[publishedForm form fields]) }
  let(:value) { :a }

  describe '#call' do
    subject do
      described_class
        .new(obj: object, args: args, ctx: ctx, value: value, field: field)
        .call(result)
    end

    let(:result) { { publishedForm: { x: :y } } }
    let(:logger) { spy('logger') }

    before { expect(GraphQL::ResultCache).to receive(:logger).twice.and_return(logger) }

    context 'with symbol callback' do
      it 'runs callback' do
        expect(object).to receive(:public_send).with(:a, result)
        subject
      end
    end

    context 'with proc callback' do
      let(:value) do
        lambda do |result, obj, args, ctx|
          "#{obj.a}-#{args[:x]}-#{ctx.path.join('/')}-#{result[:publishedForm][:x]}"
        end
      end

      it 'runs callback' do
        expect(value).to receive(:call).with(result, object, args, ctx)
        subject
      end
    end

    context 'with logging' do
      context 'with context path' do
        it 'logs callback' do
          expect(logger).to receive(:debug)
            .with('GraphQL result cache callback called for publishedForm.form.fields')
          subject
        end
      end

      context 'with field name' do
        let(:ctx) { instance_double('GraphQL::Context', path: %w[]) }

        it 'logs callback' do
          expect(logger).to receive(:debug)
            .with('GraphQL result cache callback called for publishedForm')
          subject
        end
      end
    end
  end
end
