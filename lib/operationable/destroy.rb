# frozen_string_literal: true
module Operations
  class Destroy < ::Operations::Operation
    def persist
      record.destroy
    end
  end
end
