RSpec.describe Resulting do
  it "has a version number" do
    expect(Resulting::VERSION).to_not be nil
  end

  describe ".call" do
    subject(:run) { described_class.call(result, &blk) }

    let(:test_class) do
      Class.new do
        include Resulting::Resultable
      end
    end
    let(:object) { Object.new }
    let(:result) { test_class.new(success, object) }

    let(:blk) { -> { block_success } }

    context "with a failing result" do
      let(:success) { false }

      it "returns a failure" do
        result = run

        expect(result).to be_failure
        expect(result.value).to eq(object)
      end

      it "does not call the block" do
        expect { |blk| described_class.call(result, &blk) }.to_not yield_control
      end
    end

    context "with a successful result" do
      let(:success) { true }
      let(:block_success) { [true, false].sample }

      it "returns a success with the same class" do
        result = run

        expect(result.success?).to eq(block_success)
        expect(result.value).to eq(object)
        expect(result.class).to eq(test_class)
      end

      it "does call the block" do
        expect { |blk| described_class.call(result, &blk) }.to yield_control
      end
    end

    context "with an object" do
      let(:result) { object }
      let(:success) { true }
      let(:block_success) { [true, false].sample }

      it "returns a success" do
        result = run

        expect(result.success?).to eq(block_success)
        expect(result.value).to eq(object)
        expect(result.class).to eq(Resulting::Result)
      end

      it "does call the block" do
        expect { |blk| described_class.call(result, &blk) }.to yield_control
      end
    end
  end

  describe ".configuration" do
    it "returns a new configuration if not yet defined" do
      expect(described_class.configuration).to be_a(Resulting::Configuration)
    end
  end

  xdescribe ".configure" do
    it "allows you to set options" do
    end
  end

  xdescribe ".reset_configuration" do
    it "allows you to set options" do
      described_class.configure do |config|
        config.result_alias = "MyResult"
      end

      described_class.reset_configuration

      expect(described_class.configuration.result_alias).to eq("::Result")
    end
  end
end
