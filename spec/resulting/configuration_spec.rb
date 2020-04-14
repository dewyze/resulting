RSpec.describe Resulting::Configuration do
  describe ".new" do
    it "sets the defaults" do
      config = described_class.new

      expect(config.result_alias).to eq("::Result")
    end
  end
end
