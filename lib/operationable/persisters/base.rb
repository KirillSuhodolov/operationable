module Operationable
  module Persisters
    module Base
      STATUS_INIT = 'init'
      STATUS_QUEUED = 'queued'
      STATUS_WORKING = 'working'
      STATUS_COMPLETED = 'completed'
      STATUS_FAILED = 'failed'
      STATUS_KILLED = 'killed'
      STATUSES = [
        STATUS_INIT,
        STATUS_QUEUED,
        STATUS_WORKING,
        STATUS_COMPLETED,
        STATUS_FAILED,
        STATUS_KILLED
      ].freeze
    end
  end
end
