module Resulting
  module Helpers
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def Success(*args, &block) # rubocop:disable Naming/MethodName
        Resulting::Result.success(*args, &block)
      end

      def Failure(*args, &block) # rubocop:disable Naming/MethodName
        Resulting::Result.failure(*args, &block)
      end
    end
  end
end
