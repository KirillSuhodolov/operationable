# frozen_string_literal: true
module Operations
  class Create < ::Operations::Operation
    def persist
      record.save
    end
  end
end
