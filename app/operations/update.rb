# frozen_string_literal: true
module Operations
  class Update < ::Operationable::Operation
    def persist
      record.save
    end
  end
end
