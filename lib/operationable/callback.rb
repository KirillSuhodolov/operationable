# frozen_string_literal: true
module Operationable
  class Callback
    attr_reader :props

    def initialize(props)
      @props = props
    end

    def record
      @record ||= props[:name].constantize.find(props[:id])
    end

    def user
      @user ||= User.find(props[:changed_by_id])
    end
  end
end
