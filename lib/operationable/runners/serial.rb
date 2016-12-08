# frozen_string_literal: true
module Operationable
  module Runners
    class Serial < ::Operationable::Runners::Base
      def run
        process
      end

      def process
        (queue.blank? ? self.class : OperationJob.method(perform_method)).call(options, props)
      end

      def self.call(options, props)
        instance = options[:callback_class_name].constantize.new(props)
        options[:callback_names].each { |method_name| instance.method(method_name).call }
      end

      def options
        { type: 'serial',
          callback_class_name: callback_class_name,
          callback_names: callback_names,
          queue: queue }
      end

      private

      def queue
        check_callbacks.first[:queue]
      end
    end
  end
end
