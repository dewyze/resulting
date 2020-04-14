require "resulting/version"
require "resulting/breaker"
require "resulting/configuration"
require "resulting/helpers"
require "resulting/resultable"
require "resulting/result"
require "resulting/runner"

module Resulting
  def self.call(result_or_value, wrapper: ->(&blk) { return blk.call })
    wrapper.call do
      if result_or_value.is_a?(Resulting::Resultable)
        return result_or_value if result_or_value.failure?

        value =  result_or_value.value
        klass =  result_or_value.class
      else
        value =  result_or_value
        klass =  Resulting::Result
      end

      success = yield

      klass.new(success, value)
    end
  end

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
