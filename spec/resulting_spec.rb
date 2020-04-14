RSpec.describe Resulting do
  it "has a version number" do
    expect(Resulting::VERSION).to_not be nil
  end

  describe ".configuration" do
    it "returns a new configuration if not yet defined" do
      expect(described_class.configuration).to be_a(Resulting::Configuration)
    end
  end

  describe ".configure" do
    it "allows you to set options" do
      described_class.configure do |config|
        config.result_alias = "MyResult"
      end

      expect(described_class.configuration.result_alias).to eq("MyResult")
    end
  end

  describe ".reset_configuration" do
    it "allows you to set options" do
      described_class.configure do |config|
        config.result_alias = "MyResult"
      end

      described_class.reset_configuration

      expect(described_class.configuration.result_alias).to eq("::Result")
    end
  end
end
