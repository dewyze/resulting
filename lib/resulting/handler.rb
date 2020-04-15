module Resulting
  module Handler
    include Resulting::Helpers

    def self.handle(result_or_value, wrapper: ->(&blk) { return blk.call })
      wrapper.call do
        result = Resulting::Result.wrap(result_or_value)

        return result if result.failure?

        success = yield

        result.class.new(success, result.value)
      end
    end
  end
end
