require "resulting/version"
require "resulting/configuration"
require "resulting/resultable"
require "resulting/result"

module Resulting
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Resulting::Configuration.new
    end

    def configure
      yield configuration
    end

    def reset_configuration
      @configuration = Resulting::Configuration.new
    end
  end
end
