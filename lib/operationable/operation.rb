# frozen_string_literal: true
module Operationable
  class Operation
    include Fledgedable
    include AsyncFledgedable

    do_when :valid

    attr_reader :record, :user, :params, :result

    def initialize(record, user, params={})
      @record = record
      @user = user
      @params = params
    end

    def process
      return false unless valid

      @result = build

      return false unless persist

      run

      record.reload
    end

    private

    def valid
      true
    end

    def persist
      save_record(record)
    end

    def save_record(record)
      record
    end
    
    def build
      "#{class_name}::Builder".constantize.new(record, user, params).build
    end

    def run
      push_to_queue(:run, job_class_name: lookup_operation_job, queue: job_queue, params: {})
      "#{class_name}::Runner".constantize.new(record, params, result, user).run
    end

    def lookup_operation_job

    end

    def job_queue
    
    end

    def class_name
      self.class.name
    end

    def operation_name
      self.class.to_s.split('::').last(2).map(&:underscore).join(':')
    end
  end
end
