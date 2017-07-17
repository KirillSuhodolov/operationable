# frozen_string_literal: true
module Operationable
  class Builder
    attr_reader :record, :user, :params

    def initialize(record, user, params={})
      @record = record
      @user = user
      @params = params
    end

    def build
      record
    end
  end
end
