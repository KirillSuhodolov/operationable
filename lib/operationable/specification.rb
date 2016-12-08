# frozen_string_literal: true
module Operationable
  class Specification
    attr_reader :record, :params, :activity

    def initialize(record, params={}, activity='', action_name='')
      @record = record
      @params = params
      @activity = activity
      @action_name = action_name
    end

    def satisfied_by?(list, record)
      (list & record.previous_changes.keys).any?
    end
  end
end
