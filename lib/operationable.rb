require 'rails'
require 'active_support/dependencies'

require "operationable/version"

require 'operationable/builder'
require 'operationable/callback'
require 'operationable/operation'
require 'operationable/serializer'
require 'operationable/specification'

require 'operationable/runners/base'
require 'operationable/runners/serial'
require 'operationable/runners/separate'

require 'jobs/operation_job'
require 'operations/create'
require 'operations/destroy'
require 'operations/update'

module Operationable

end
