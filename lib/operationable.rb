require 'rails'
require 'active_job'
require 'active_support/dependencies'
require 'forwardable'
require 'resque'
require 'resque-status'

require "operationable/version"

require 'operationable/builder'
require 'operationable/callback'
require 'operationable/operation'
require 'operationable/serializer'
require 'operationable/specification'
require 'operationable/persister'

require 'operationable/runners/base'
require 'operationable/runners/serial'
require 'operationable/runners/separate'

require 'jobs/operation_job'
require 'operations/create'
require 'operations/destroy'
require 'operations/update'

module Operationable
  attr_reader :job_class, :job_sync_execute_method, :job_async_execute_method

  @job_class = 'OperationJob'
  @job_sync_execute_method = :create # :perform_now
  @job_async_execute_method = :create # :perform_later

  class Operation
    class Builder < ::Operationable::Builder; end
    class Callback < ::Operationable::Callback; end
    class Specification < ::Operationable::Specification; end
    class Serializer < ::Operationable::Serializer; end
    class Persister < ::Operationable::Persister; end
  end
end
