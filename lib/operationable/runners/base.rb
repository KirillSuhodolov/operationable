# frozen_string_literal: true
module Operations
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

      # contstans deprecated, use example below
      # def initialize_callbacks
      #   push_to_queue(:method_name, :queue)
      #   push_to_queue(:broadcast, :low)
      #   push_to_queue(:notify, :low)
      #   push_to_queue(:populate_feed, :low)
      # end

      SYNC = %i().freeze
      CRITICAL_QUEUE = %i().freeze
      IMPORTANT_QUEUE = %i().freeze
      HIGH_QUEUE = %i().freeze
      LOW_QUEUE = %i().freeze
      MAILER_QUEUE = %i().freeze

      def run
      end

      private

      def props
        serializer_instance.serialize
      end

      def queue_hash
        hash_map = { SYNC: nil }
        queues.each_key { |key| hash_map["#{key.upcase}_QUEUE".to_sym] = key }
        hash_map
      end

      def initialize_callbacks
        queue_hash.each do |const_name, queue|
          self.class.const_get(const_name).each do |callback_method_name|
            push_to_queue(callback_method_name, queue)
          end
        end
      end

      def push_to_queue(callback_method_name, queue=nil)
        callbacks << {
          callback_method_name: callback_method_name.to_s,
          queue: queue.to_s
        }
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
        @specification ||= specification_class_name.constantize.new(record, params, activity, action_name)
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

      def queues
        RESQUE_QUEUES
      end

      def perform_method
        sync? ? :perform_now : :perform_later
      end

      def sync?
        %w(test development).include? Rails.env
      end
    end
  end
end
