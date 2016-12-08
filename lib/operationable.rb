require 'rails'
require 'active_support/dependencies'

require "operationable/version"

require 'operationable/builder'
require 'operationable/callback'
require 'operationable/operation'
require 'operationable/serializer'
require 'operationable/specification'

# require 'operationable/create'
# require 'operationable/destroy'
# require 'operationable/update'

# require 'operationable/job'

require 'operationable/runners/base'
require 'operationable/runners/serial'
require 'operationable/runners/separate'

require '../app/jobs/operation_job'
require '../app/operations/create'
require '../app/operations/destroy'
require '../app/operations/update'

module Operationable

end
