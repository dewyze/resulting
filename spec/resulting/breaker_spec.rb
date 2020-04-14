RSpec.describe Resulting::Breaker do
  let(:record) { Struct.new(:save) }

  let(:foo_obj) { instance_double(record, save: true) }
  let(:bar_obj) { instance_double(record, save: true) }
  let(:bumble_obj) { instance_double(record, save: false) }
  let(:params) { Hash(foo: foo_obj, bar: bar_obj) }
  let(:result) { Resulting::Result.success(params) }

  let(:blk) { -> { block_success } }
  let(:wrapper) { ->(&blk) { blk.call } }

  describe ".call" do
    subject(:run) { described_class.call(result, method: :save, &blk) }

    it "uses Resulting.call" do
      expect(Resulting).to receive(:call).with(result, wrapper: wrapper)

      described_class.call(result, method: :save, wrapper: wrapper)
    end

    context "with successful params" do
      context "without a block" do
        subject(:run) { described_class.call(result, method: :save) }

        it "returns a successful result" do
          expect(run).to be_success
        end

        it "assigns the params to methods in the result" do
          value = run.value

          expect(value[:foo]).to eq(foo_obj)
          expect(value[:bar]).to eq(bar_obj)
        end

        it "calls save on each object" do
          expect(foo_obj).to receive(:save)
          expect(bar_obj).to receive(:save)

          run.value
        end
      end

      context "with a successful block" do
        let(:block_success) { true }

        it "returns a successful result" do
          expect(run).to be_success
        end

        it "calls the block" do
          expect do |blk|
            described_class.call(result, method: :save, &blk)
          end.to yield_control
        end
      end

      context "with a failing block" do
        let(:block_success) { false }

        it "returns a successful result" do
          expect(run).to be_failure
        end

        it "calls the block" do
          expect do |blk|
            described_class.call(result, method: :save, &blk)
          end.to yield_control
        end
      end
    end

    context "with failing params" do
      let(:params) { Hash(bumble: bumble_obj, foo: foo_obj) }
      let(:block_success) { true }

      it "returns a failing result" do
        expect(run).to be_failure
      end

      it "assigns the params to methods in the result" do
        value = run.value

        expect(value[:bumble]).to eq(bumble_obj)
        expect(value[:foo]).to eq(foo_obj)
      end

      it "does call save on the first object after failure" do
        expect(bumble_obj).to receive(:save)
        expect(foo_obj).to_not receive(:save)

        run.value
      end

      it "does not call the block" do
        expect do |blk|
          described_class.call(result, method: :save, &blk)
        end.to_not yield_control
      end
    end
  end
end
