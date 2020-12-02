require 'rails'
require 'active_job'
require 'active_support/dependencies'
require 'forwardable'

require "operationable/version"
require 'operationable/builder'
require 'operationable/callback'
require 'operationable/operation'
require 'operationable/serializer'
require 'operationable/specification'

require 'operationable/runners/base'
require 'operationable/runners/serial'
require 'operationable/runners/separate'

require 'operations/create'
require 'operations/destroy'
require 'operations/update'

module Operationable
  class Operation
    class Builder < ::Operationable::Builder; end
    class Callback < ::Operationable::Callback; end
    class Specification < ::Operationable::Specification; end
    class Serializer < ::Operationable::Serializer; end
  end
end
