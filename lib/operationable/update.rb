# frozen_string_literal: true
module Operations
  class Update < ::Operations::Operation
    def persist
      record.save
    end
  end
end
