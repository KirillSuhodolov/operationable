# frozen_string_literal: true
module Operations
  class Create < ::Operationable::Operation
    def persist
      record.save
    end
  end
end
