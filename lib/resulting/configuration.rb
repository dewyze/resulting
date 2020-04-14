module Resulting
  class Configuration
    attr_accessor :result_alias

    def initialize
      @result_alias = "::Result"
    end
  end
end
