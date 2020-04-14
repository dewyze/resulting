RSpec.describe Resulting::Helpers do
  let!(:klass) do
    Class.new { include Resulting::Helpers }
  end

  describe "Success()" do
    it "creates a method that creats a success result" do
      success = nil
      value = Object.new
      klass.class_eval do
        success = Success(value)
      end

      expect(success).to be_a(Resulting::Result)
      expect(success).to be_success
      expect(success.value).to eq(value)
    end
  end

  describe "Failure()" do
    it "creates a method that creats a failure result" do
      failure = nil
      value = Object.new
      klass.class_eval do
        failure = Failure(value)
      end

      expect(failure).to be_a(Resulting::Result)
      expect(failure).to be_failure
      expect(failure.value).to eq(value)
    end
  end
end
