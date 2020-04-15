RSpec.describe Resulting::Resultable do
  let(:resultable) { Class.new { include Resulting::Resultable } }

  let(:success) { [true, false].sample }

  describe ".success" do
    subject(:run) { resultable.success(value) }

    let(:success) { true }
    let(:value) { :foo }

    it "calls new and returns a successful result" do
      expect(resultable).to receive(:new).with(success, value).and_call_original

      result = run

      expect(result).to be_success
      expect(result).to_not be_failure
    end
  end

  describe ".failure" do
    subject(:run) { resultable.failure(value) }

    let(:success) { false }
    let(:value) { :foo }

    it "calls new and returns a successful result" do
      expect(resultable).to receive(:new).with(success, value).and_call_original

      result = run

      expect(result).to be_failure
      expect(result).to_not be_success
    end
  end

  describe ".new" do
    subject(:run) { resultable.new(success, value) }

    let(:object) { Object.new }

    context "with an object" do
      let(:value) { object }

      it "returns a successful result and sets the value" do
        result = run

        expect(result.value).to eq(value)
      end
    end

    context "with a result" do
      let(:value) { resultable.success(object) }

      it "returns a successful result and sets the value" do
        result = run

        expect(result.value).to eq(object)
      end
    end
  end

  describe ".wrap" do
    subject(:run) { resultable.wrap(param) }

    let(:value) { Object.new }

    context "with a result" do
      let(:param) { resultable.success(value) }

      it "returns the same result" do
        result = run

        expect(result.class).to eq(resultable)
        expect(result).to eq(param)
      end
    end

    context "with an object" do
      let(:param) { value }

      it "wraps the object in a result" do
        result = run

        expect(result.class).to eq(resultable)
        expect(result.value).to eq(param)
      end
    end
  end

  describe "#values" do
    subject(:run) { resultable.new(success, value) }

    context "with an object" do
      let(:value) { Object.new }

      it "returns the value in an array" do
        expect(run.values).to match_array([value])
      end
    end

    context "with a hash" do
      let(:object_1) { Object.new }
      let(:object_2) { Object.new }
      let(:value) { Hash(a: object_1, b: object_2) }

      it "returns the value in an array" do
        expect(run.values).to match_array([object_1, object_2])
      end
    end

    context "with an array" do
      let(:object_1) { Object.new }
      let(:object_2) { Object.new }
      let(:value) { [object_1, object_2] }

      it "returns the value in an array" do
        expect(run.values).to match_array(value)
      end
    end

    context "with a nested array" do
      let(:object_1) { Object.new }
      let(:object_2) { Object.new }
      let(:object_3) { Object.new }
      let(:value) { [object_1, [object_2, object_3]] }

      it "returns the value in an array" do
        expect(run.values).to match_array([object_1, object_2, object_3])
      end
    end
  end
end
