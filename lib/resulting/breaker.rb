module Resulting
  module Breaker
    def self.call(result, method:, failure_case: -> { false }, wrapper: ->(&blk) { blk.call })
      Resulting.call(result, wrapper: wrapper) do
        result = result.values.all?(&method)

        result &&= yield if block_given?

        result ? true : failure_case.call
      end
    end
  end
end
