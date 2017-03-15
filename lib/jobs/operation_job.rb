# frozen_string_literal: true
class OperationJob < ActiveJob::Base
  queue_as do
    arguments.first[:q_options][:queue]
  end

  def perform(q_options:, props:)
    "Operationable::Runners::#{q_options[:type].capitalize}".constantize.call(q_options: q_options, props: props)
  end
end
