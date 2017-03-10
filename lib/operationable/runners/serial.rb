# frozen_string_literal: true
module Operationable
  module Runners
    class Serial < ::Operationable::Runners::Base
      def run
        process
      end

      def process
        (queue.blank? ? self.class : OperationJob.method(perform_method)).call(
          q_options: q_options,
          props: props
        )
      end

      def self.call(q_options:, props:)
        instance = q_options[:callback_class_name].constantize.new(props)
        q_options[:callback_names].each { |method_name| instance.method(method_name).call }
      end

      # TODO: No sense, due to performance deterioration, better use postgres/mysql database
      # def self.call(q_options, props)
      #   instance = q_options[:callback_class_name].constantize.new(props)
      #
      #   q_options[:callback_names].each do |method_name|
      #     ::Operationable::Persister.around_call(q_options[:op_id], method_name, -> {
      #       instance.method(method_name).call
      #     })
      #   end
      # end

      def q_options
        { type: 'serial',
          callback_class_name: callback_class_name,
          callback_names: callback_names,
          queue: queue,
          op_id: persist_operation.id }
      end

      private

      def queue
        check_callbacks.first[:queue]
      end
    end
  end
end
