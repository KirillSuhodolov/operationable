# frozen_string_literal: true
module Operations
  class Destroy < ::Operationable::Operation
    def persist
      record.destroy
    end
  end
end
