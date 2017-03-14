# frozen_string_literal: true
module Operationable
  module Runners
    class Base
      attr_reader :callbacks, :record, :user, :params, :result

      def initialize(record, params, result, user)
        @record = record
        @params = params
        @result = result
        @user = user
        @callbacks = []

        initialize_callbacks
      end

      def store_callback(q_options)
        q_options
      end

      def check_status?
        true
      end

      def persist?
        true
      end

      def run
      end

      def ensure_enqueue

      end

      def job_method
        "#{job_class}".constantize.method(perform_method)
      end

      def job_class
        'OperationJob'
      end

      def job_sync_execute_method
        :perform_later
      end

      def job_async_execute_method
        :perform_later
      end

      private

      def props
        serializer_instance.serialize
      end

      def initialize_callbacks
      end

      def push_to_queue(*callback_method_names, queue: nil)
        callback_method_names.each do |callback_method_name|
          callbacks << { callback_method_name: callback_method_name.to_s, queue: queue.to_s }
        end
      end

      def callback_names
        check_callbacks.map { |callback| callback[:callback_method_name] }
      end

      def check_callbacks
        callbacks.find_all do |callback|
          satisfy = specification&.try("should_#{callback[:callback_method_name]}".to_sym)
          satisfy.nil? || satisfy
        end
      end

      def serializer_instance
        serializer_class_name.constantize.new(record, user, params, result, activity, action_name)
      end

      def specification
        @specification ||= specification_class_name.constantize.new(record, user, params, activity, action_name)
      end

      def callback_class_name
        "#{operation_class_name}::Callback"
      end

      def serializer_class_name
        "#{operation_class_name}::Serializer"
      end

      def specification_class_name
        "#{operation_class_name}::Specification"
      end

      def operation_class_name
        self.class.name.chomp('::Runner')
      end

      def activity
        operation_class_name.split('::').last.underscore
      end

      def action_name
        operation_class_name.split('::')[-2..-1].join(' ').titleize
      end

      def class_name
        self.class.name
      end

      def perform_method
        sync? ? job_sync_execute_method : job_async_execute_method
      end

      def sync?
        %w(test development).include? Rails.env
      end
    end
  end
end
