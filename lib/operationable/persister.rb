# frozen_string_literal: true
module Operationable
  class Persister
    class << self
      def persist(callbacks, initiator_id, params, name)
        ::Operation.create(
          callbacks: callbacks.map { |callback|
            {
              status: ::Operation::STATUS_INIT,
              name: callback[:callback_method_name],
              queue: callback[:queue]
            }
          },
          initiator_id: initiator_id,
          params: params,
          name: name
        )
      end

      def working(id, name)
        update(id, name, ::Operation::STATUS_WORKING)
      end

      def completed
        update(id, name, ::Operation::STATUS_COMPLETED)
      end

      def around_call(id, name, block)
        working(id, name)
        block.call
        completed(id, name)
      end

      private

      def update(id, name, status)
        op = ::Operation.find(id)
        callbacks = op.callbacks.map do |cb|
          cb['status'] = status if cb['name'] === name
          cb
        end

        op.callbacks = callbacks
        op.save
      end
    end
  end
end
