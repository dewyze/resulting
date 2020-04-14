module Resulting
  module Runner
    def self.run_all(result, method:, failure_case: -> { false }, wrapper: ->(&blk) { blk.call })
      Resulting::Handler.handle(result, wrapper: wrapper) do
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

    def self.run_until_failure(result, method:, failure_case: -> { false }, wrapper: ->(&blk) { blk.call })
      Resulting::Handler.handle(result, wrapper: wrapper) do
        result = result.values.all?(&method)

        result &&= yield if block_given?

        result ? true : failure_case.call
      end
    end
  end
end
