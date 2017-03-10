# frozen_string_literal: true
module Operationable
  module Runners
    class Separate < ::Operationable::Runners::Base
      def run
        check_callbacks.each { |callback| process(callback) }
      end

      def process(callback_method_name:, queue: nil)
        (queue.blank? ? self.class : OperationJob.method(perform_method)).call(options(callback_method_name, queue), props)
      end

      def options(callback_method_name, queue)
        { type: 'separate',
          callback_class_name: callback_class_name,
          callback_method_name: callback_method_name,
          queue: queue }
      end

      # def self.call(options, props)
      #   options[:callback_class_name].constantize.new(props).method(options[:callback_method_name]).call
      # end

      def self.call(options, props)
        ::Operationable::Persister.around_call(props, options[:callback_method_name], -> {
          options[:callback_class_name].constantize.new(props).method(options[:callback_method_name]).call
        })
      end

    end
  end
end
