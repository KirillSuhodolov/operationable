# frozen_string_literal: true
class OperationJob #< ActiveJob::Base
  include Resque::Plugins::Status

  # queue_as do
  #   arguments.first[:queue]
  # end

  @queue = :important

  def perform(q_options:, props:)
    "Operationable::Runners::#{q_options[:type].capitalize}".constantize.call(q_options: q_options, props: props)
  end

  # after_perform do
  #   ActiveRecord::Base.clear_active_connections!
  #   GC.start
  # end
end
