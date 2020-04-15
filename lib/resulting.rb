require "resulting/version"
require "resulting/configuration"
require "resulting/resultable"
require "resulting/helpers"
require "resulting/handler"
require "resulting/result"
require "resulting/runner"

module Resulting
  class << self
    attr_writer :configuration

    def validate(result_or_value, &blk)
      Resulting::Runner.run_all(result_or_value, method: :validate, &blk)
    end

    def save(result_or_value, &blk)
      params = { method: :save }

      if defined?(ActiveRecord::Base) && defined?(ActiveRecord::Rollback)
        params[:failure_case] = -> { raise ActiveRecord::Rollback }
        params[:wrapper] = ActiveRecord::Base.method(:transaction)
      end

      Resulting::Runner.run_until_failure(result_or_value, params, &blk)
    end

    def validate_and_save(result_or_value)
      save(validate(result_or_value))
    end

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
