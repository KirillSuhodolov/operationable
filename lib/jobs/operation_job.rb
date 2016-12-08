# frozen_string_literal: true
class OperationJob < ActiveJob::Base
  queue_as do
    arguments.first[:queue]
  end

  def perform(options, props)
    "Operationable::Runners::#{options[:type].capitalize}".constantize.call(options, props)
  end

  after_perform do
    ActiveRecord::Base.clear_active_connections!
    GC.start
  end
end