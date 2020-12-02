# frozen_string_literal: true
module Operationable
  class Delayer
    attr_reader :record, :user, :params, :result, :activity, :action_name

    def initialize(record, user, params={}, result=nil, activity='', action_name='')
      @record = record
      @user = user
      @params = params
      @result = result
      @activity = activity
      @action_name = action_name
    end
  end
end
