# frozen_string_literal: true
module Operations
  module Runners
    class Separate < ::Operations::Runners::Base
      def run
        check_callbacks.each { |callback| process(callback) }
      end

      def process(callback_method_name:, queue: nil)
        (queue ? OperationJob.method(perform_method) : self.class).call(options(callback_method_name, queue), props)
      end

      def options(callback_method_name, queue)
        { type: 'separate',
          callback_class_name: callback_class_name,
          callback_method_name: callback_method_name,
          queue: queue }
      end

      def self.call(options, props)
        options[:callback_class_name].constantize.new(props).method(options[:callback_method_name]).call
      end
    end
  end
end
