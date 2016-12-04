# frozen_string_literal: true
module Operations
  class Operation
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
      record
    end

    def build
      "#{class_name}::Builder".constantize.new(record, params).build
    end

    def run
      "#{class_name}::Runner".constantize.new(record, params, result, user).run
    end

    def class_name
      self.class.name
    end
  end
end
