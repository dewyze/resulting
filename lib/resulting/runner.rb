module Resulting
  module Runner
    def self.call(result, method:, failure_case: -> { false }, wrapper: ->(&blk) { blk.call })
      Resulting.call(result, wrapper: wrapper) do
        new_result = result.values.reduce(true) do |success, v|
          v.send(method) ? success : false
        end

        if block_given?
          block_result = yield
          new_result &&= block_result
        end

        new_result ? true : failure_case.call
      end
    end
  end
end
