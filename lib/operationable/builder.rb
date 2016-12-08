# frozen_string_literal: true
module Operationable
  class Builder
    attr_reader :record, :params

    def initialize(record, params={})
      @record = record
      @params = params
    end

    def build
      record
    end
  end
end
