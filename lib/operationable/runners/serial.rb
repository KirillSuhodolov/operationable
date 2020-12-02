# frozen_string_literal: true
# TODO: never used, may be remove
module Operationable
  module Runners
    class Serial < ::Operationable::Runners::Base
      def run
        process
      end

      def process
        (queue.blank? ? self.class : perform(job_class_name)).call(
          q_options: q_options,
          props: props
        )
      end

      def self.call(q_options:, props:)
        instance = q_options[:callback_class_name].constantize.new(props, q_options)
        q_options[:callback_names].each { |method_name| instance.method(method_name).call }
      end

      def q_options
        store_callback({ type: 'serial',
          callback_class_name: callback_class_name,
          callback_names: callback_names,
          queue: queue })
      end

      def callback_names
        check_callbacks.map { |callback| callback[:callback_method_name] }
      end

      private

      def queue
        check_callbacks.first[:queue]
      end
    end
  end
end
