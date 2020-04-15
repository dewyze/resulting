RSpec.describe Resulting do
  let(:record) { Struct.new(:validate, :save) }

  it "has a version number" do
    expect(Resulting::VERSION).to_not be nil
  end

  describe ".validate" do
    subject(:run) { described_class.validate(param) }

    let(:value) { instance_double(record, validate: true, save: true) }
    let(:param) { Resulting::Result.success(value) }

    it "calls the runner with the validate command" do
      expect(Resulting::Runner).to receive(:run_all).with(param, method: :validate)

      run
    end

    it "yields to the block" do
      expect do |blk|
        described_class.validate(param, &blk)
      end.to yield_control
    end
  end

  describe ".save" do
    subject(:run) { described_class.save(param) }

    let(:value) { instance_double(record, validate: true, save: true) }
    let(:param) { Resulting::Result.success(value) }

    context "without Rails defined" do
      it "calls the runner with the save command" do
        expect(Resulting::Runner).to receive(:run_until_failure).with(param, method: :save)

        run
      end

      it "yields to the block" do
        expect do |blk|
          described_class.save(param, &blk)
        end.to yield_control
      end
    end

    context "with Rails defined" do
      let(:rails) { Class.new }
      let(:active_record) { Class.new { def self.transaction; end } }
      let(:rollback) { Class.new(StandardError) }

      it "calls the runner in a transaction and with 'raise ActiveRecord::Rollback' failure case" do
        stub_const("Rails", rails)
        stub_const("ActiveRecord::Base", active_record)
        stub_const("ActiveRecord::Rollback", rollback)

        expect(Resulting::Runner).to receive(:run_until_failure) do |*params|
          result_or_value = params[0]
          options = params[1]

          expect(result_or_value).to eq(param)
          expect(options[:method]).to eq(:save)
          expect(options[:wrapper]).to eq(active_record.method(:transaction))

          expect do
            options[:failure_case].call
          end.to raise_error(rollback)
        end

        run
      end

      it "yields to the block" do
        expect do |blk|
          described_class.save(param, &blk)
        end.to yield_control
      end
    end
  end

  describe ".validate_and_save" do
    subject(:run) { described_class.validate_and_save(param) }

    let(:value) { instance_double(record, validate: true, save: true) }
    let(:param) { Resulting::Result.success(value) }
    let(:validation_result) { Resulting::Result.success(value) }
    let(:save_result) { Resulting::Result.success(value) }

    it "calls the validate and save methods" do
      expect(described_class).to receive(:validate).with(param).and_return(validation_result)
      expect(described_class).to receive(:save).with(validation_result).and_return(save_result)

      expect(run).to eq(save_result)
    end
  end
end
