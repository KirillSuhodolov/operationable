# frozen_string_literal: true
class OperationJob < ActiveJob::Base
  include Operationable::Persisters::Memory
  # include Operationable::Persister

  queue_as do
    arguments.first[:q_options][:queue]
  end

  after_enqueue do |job|
    create_status_hash(job)
  end

  around_perform do |job, block|
    safe_perform(job, block)
  end

  after_perform :clear_runtime

  def perform(q_options:, props:)
    "Operationable::Runners::#{q_options[:type].capitalize}".constantize.call(q_options: q_options, props: props)
  end

  private

  def clear_runtime
    ActiveRecord::Base.clear_active_connections!
    GC.start
  end
end
