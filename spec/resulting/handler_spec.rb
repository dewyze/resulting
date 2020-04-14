RSpec.describe Resulting::Handler do
  describe ".handle" do
    subject(:run) { described_class.handle(result, &blk) }

    let(:test_class) do
      Class.new do
        include Resulting::Resultable
      end
    end
    let(:object) { Object.new }
    let(:result) { test_class.new(success, object) }

    let(:blk) { -> { block_success } }
    let(:block_success) { [true, false].sample }

    context "with a failing result" do
      let(:success) { false }

      it "returns a failure" do
        result = run

        expect(result).to be_failure
        expect(result.value).to eq(object)
      end

      it "does not call the block" do
        expect { |blk| described_class.handle(result, &blk) }.to_not yield_control
      end
    end

    context "with a successful result" do
      let(:success) { true }

      it "returns a success with the same class" do
        result = run

        expect(result.success?).to eq(block_success)
        expect(result.value).to eq(object)
        expect(result.class).to eq(test_class)
      end

      it "does call the block" do
        expect { |blk| described_class.handle(result, &blk) }.to yield_control
      end
    end

    context "with an object" do
      let(:result) { object }
      let(:success) { true }

      it "returns a success" do
        result = run

        expect(result.success?).to eq(block_success)
        expect(result.value).to eq(object)
        expect(result.class).to eq(Resulting::Result)
      end

      it "does call the block" do
        expect { |blk| described_class.handle(result, &blk) }.to yield_control
      end
    end

    context "with a wrapper" do
      subject(:run) { described_class.handle(result, wrapper: wrapper, &blk) }

      let(:wrapper) { ->(&blk) { return blk.call } }

      context "with a successful param" do
        let(:success) { true }
        let(:block_success) { true }

        it "calls the block" do
          expect(wrapper).to receive(:call).and_call_original

          result = run

          expect(result).to be_success
        end
      end

      context "with a failing param" do
        let(:success) { false }

        it "calls the block" do
          expect(wrapper).to receive(:call).and_call_original

          result = run

          expect(result).to be_failure
        end
      end
    end
  end
end
