# frozen_string_literal: true
class OperationJob < ::ActiveJob::Base # ApplicationJob
  queue_as do
    arguments.first[:queue]
  end

  def perform(options, props)
    "Operationable::Runners::#{options[:type].capitalize}".constantize.call(options, props)
  end
end
