# frozen_string_literal: true
module Operationable
  module Runners
    class Separate < ::Operationable::Runners::Base
      def run
        check_callbacks.each { |callback| process(callback) }
      end

      def process(callback_method_name:, job_class_name: nil, queue: nil, params:)
        # callback can be class
        # callback_class = callback_method_name.to_s.safe_constantize

        args = {
          q_options: q_options(callback_method_name, queue),
          props: props.merge(params)
        }

        queue.blank? ? self.class.call(args) : perform(job_class_name, args, get_delayed_params(callback_method_name))
      end

      def get_delayed_params(callback_method_name)
        delay = delayer&.try("delay_#{callback_method_name}".to_sym)
        delay.nil? ? {} : delay
      end

      def q_options(callback_method_name, queue)
        store_callback({ type: 'separate',
          callback_class_name: callback_class_name,
          callback_method_name: callback_method_name,
          queue: queue })
      end

      def self.call(q_options:, props:)
        q_options[:callback_class_name].constantize.new(props, q_options).method(q_options[:callback_method_name]).call
      end
    end
  end
end
