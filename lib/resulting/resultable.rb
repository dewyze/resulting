module Resulting
  module Resultable
    def self.included(base)
      base.extend ClassMethods
      attr_reader :success, :value
    end

    def initialize(success, value)
      @success = success
      @value = value.is_a?(Resulting::Resultable) ? value.value : value
    end

    def success?
      @success
    end

    def failure?
      !@success
    end

    def values
      if value.is_a?(Hash)
        value.values.flatten
      else
        Array(value).flatten
      end
    end

    module ClassMethods
      def success(value)
        new(true, value)
      end

      def failure(value)
        new(false, value)
      end

      def wrap(param)
        return param if param.is_a?(Resulting::Resultable)

        success(param)
      end
    end
  end
end
