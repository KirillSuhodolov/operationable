# frozen_string_literal: true
module Operationable
  module Runners
    class Separate < ::Operationable::Runners::Base
      # def run
      #   check_callbacks.each { |callback| process(callback) }
      # end

      # def process(callback_method_name:, job_class_name: nil, queue: nil, params:)
      #   args = {
      #     q_options: q_options(callback_method_name, queue).to_h,
      #     props: props.merge(params).to_h
      #   }.to_h.deep_stringify_keys
  
      #   queue.blank? ? self.class.call(args) : perform(job_class_name, args, get_delayed_params(callback_method_name))
      # end

      # def get_delayed_params(callback_method_name)
      #   delay = delayer&.try("delay_#{callback_method_name}".to_sym)
      #   delay.nil? ? {} : delay
      # end

      # def q_options(callback_method_name, queue)
      #   store_callback({ type: 'separate',
      #     callback_class_name: callback_class_name,
      #     callback_method_name: callback_method_name,
      #     queue: queue })
      # end

      # class << self
      #   def operation_name
      #     self.to_s.split('::').last(3).first(2).map(&:underscore).join(':')
      #   end
    
      #   def call(params)
      #     q_options = extract_q_options(params)
      #     props = extract_props(params)
  
      #     q_options[:callback_class_name].constantize.new(props, q_options).method(q_options[:callback_method_name]).call
      #   end
  
      #   def extract_props(params)
      #     params['props'].deep_symbolize_keys
      #   end
  
      #   def extract_q_options(params)
      #     params['q_options'].deep_symbolize_keys
      #   end
      # end
    end
  end
end
