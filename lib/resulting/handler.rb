module Resulting
  module Handler
    def self.handle(result_or_value, wrapper: ->(&blk) { return blk.call })
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
  end
end
