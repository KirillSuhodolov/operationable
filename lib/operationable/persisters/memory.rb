# frozen_string_literal: true
# codebase has been taken from abandoned resque-status gem, that not compatible with ActiveJob and Rails now
module Operationable
  module Persisters
    module Memory
      autoload :Hash, 'resque/plugins/status/hash'

      def create_status_hash
        Resque::Plugins::Status::Hash.create(uuid, options)
      end

      # Set the jobs status. Can take an array of strings or hashes that are merged
      # (in order) into a final status hash.
      def status=(new_status)
        Resque::Plugins::Status::Hash.set(uuid, *new_status)
      end

      # get the Resque::Plugins::Status::Hash object for the current uuid
      def status
        Resque::Plugins::Status::Hash.get(uuid)
      end

      # Checks against the kill list if this specific job instance should be killed
      # on the next iteration
      def should_kill?
        Resque::Plugins::Status::Hash.should_kill?(uuid)
      end

      # set the status of the job for the current itteration. <tt>num</tt> and
      # <tt>total</tt> are passed to the status as well as any messages.
      # This will kill the job if it has been added to the kill list with
      # <tt>Resque::Plugins::Status::Hash.kill()</tt>
      def at(num, total, *messages)
        if total.to_f <= 0.0
          raise(NotANumber, "Called at() with total=#{total} which is not a number")
        end
        tick({
          'num' => num,
          'total' => total
        }, *messages)
      end

      # sets the status of the job for the current itteration. You should use
      # the <tt>at</tt> method if you have actual numbers to track the iteration count.
      # This will kill the job if it has been added to the kill list with
      # <tt>Resque::Plugins::Status::Hash.kill()</tt>
      def tick(*messages)
        kill! if should_kill?
        set_status({'status' => Operationable::Persisters::Base::STATUS_WORKING}, *messages)
      end

    end
  end
end
