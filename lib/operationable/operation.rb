# frozen_string_literal: true
module Operationable
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

    class Builder < Operationable::Builder; end
    class Callback < Operationable::Callback; end
    class Specification < Operationable::Callback; end
    class Serializer < Operationable::Serializer; end

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
