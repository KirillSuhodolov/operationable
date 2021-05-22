# frozen_string_literal: true
module Operationable
  module Runners
    module Wrappable
      def push_to_queue(*callback_method_names, job_class_name: nil, queue: nil, params: {})
        callback_method_names.each do |callback_method_name|
          callbacks << {
            callback_method_name: callback_method_name.to_s,
            job_class_name: job_class_name.nil? ? job_class.to_s : job_class_name.to_s,
            queue: (job_class_name && queue.blank?) ? job_class_name.to_s.constantize.queue_name : queue.to_s,
            params: params
          }
        end
      end
  
      def add_part(modul, opts=nil)
        modul.execute(self, opts)
      end
  
      def callbacks
        @callbacks ||= []
      end
  
      def inherited_callbacks
        ancestors
          .grep(Wrappable)
          .reverse
          .flat_map(&:callbacks)
      end
  
      def new(*arguments, &block)
        instance = allocate
        instance.send(:initialize, *arguments, &block)
        instance_callbacks = instance.instance_variable_get(:@callbacks)
        instance.instance_variable_set(:@callbacks, instance_callbacks.concat(inherited_callbacks).uniq)
        instance
      end
    end
    
    class Base
      attr_reader :callbacks, :record, :user, :params, :result

      # extend Wrappable

      include Operationable::Fledgedable
      include Operationable::AsyncFedgedable

      class << self
        def operation_name
          self.to_s.split('::').last(3).first(2).map(&:underscore).join(':')
        end
    
        def call(params)
          q_options = extract_q_options(params)
          props = extract_props(params)
  
          q_options[:callback_class_name].constantize.new(props, q_options).method(q_options[:callback_method_name]).call
        end
  
        def extract_props(params)
          params['props'].deep_symbolize_keys
        end
  
        def extract_q_options(params)
          params['q_options'].deep_symbolize_keys
        end
      end

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
        check_callbacks.each { |callback| process(callback) }
      end

      def process(callback_method_name:, job_class_name: nil, queue: nil, params:)
        args = {
          q_options: q_options(callback_method_name, queue).to_h,
          props: props.merge(params).to_h
        }.to_h.deep_stringify_keys
  
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

      def push_to_queue(*callback_method_names, job_class_name: nil, queue: nil, params: {})
        callback_method_names.each do |callback_method_name|
          callbacks << {
            callback_method_name: callback_method_name.to_s,
            job_class_name: job_class_name.nil? ? job_class.to_s : job_class_name.to_s,
            queue: queue.to_s,
            params: params
          }
        end
      end

      def check_callbacks
        callbacks.find_all do |callback|
          satisfy = specification&.try("should_#{callback[:callback_method_name]}".to_sym)
          satisfy.nil? || satisfy
        end
      end

      def serializer_instance
        @serializer_instance ||= serializer_class_name.constantize.new(record, user, params, result, activity, action_name)
      end

      def delayer
        @delayer ||= delayer_class_name.constantize.new(record, user, params, result, activity, action_name)
      end

      def specification
        @specification ||= specification_class_name.constantize.new(record, user, params, result, activity, action_name)
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

      def delayer_class_name
        "#{operation_class_name}::Delayer"
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

      def perform(job_class_name, args, delayed_params)
        job_class_name.to_s.constantize.set(delayed_params).method(perform_method).call(args)
      end

      def sync?
        %w(test development).include? Rails.env
      end
    end
  end
end
