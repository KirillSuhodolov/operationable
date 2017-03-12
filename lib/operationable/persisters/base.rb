module Operationable
  module Persisters
    module Base
      STATUS_INIT = 'init'
      STATUS_QUEUED = 'queued'
      STATUS_WORKING = 'working'
      STATUS_COMPLETED = 'completed'
      STATUS_FAILED = 'failed'
      STATUS_KILLED = 'killed'
      STATUSES = [
        STATUS_INIT,
        STATUS_QUEUED,
        STATUS_WORKING,
        STATUS_COMPLETED,
        STATUS_FAILED,
        STATUS_KILLED
      ].freeze

      extend Forwardable
      extend ActiveSupport::Concern

      class Killed < RuntimeError; end
      class NotANumber < RuntimeError; end

      # attr_reader :uuid, :options

      def uuid
        self.job_id
      end

      def options
        arguments.first
      end

      # Run by the Resque::Worker when processing this job. It wraps the <tt>perform</tt>
      # method ensuring that the final status of the job is set regardless of error.
      # If an error occurs within the job's work, it will set the status as failed and
      # re-raise the error.
      def safe_perform(job, block)
        working
        block.call
        if status && status.failed?
          on_failure(status.message) if respond_to?(:on_failure)
          return
        elsif status && !status.completed?
          completed
        end
        on_success if respond_to?(:on_success)
      rescue Killed
        Resque::Plugins::Status::Hash.killed(uuid)
        on_killed if respond_to?(:on_killed)
      rescue => e
        failed("The task failed because of an error: #{e}")
        if respond_to?(:on_failure)
          on_failure(e)
        else
          raise e
        end
      end

      def name
        "#{self.class.name}(#{callback_class_name} #{callback_method_name})"
      end

      def callback_class_name
        arguments.first[:q_options][:callback_class_name]
      end

      def callback_method_name
        arguments.first[:q_options][:callback_method_name]
      end

      def working
        set_status({'status' => Operationable::Persisters::Base::STATUS_WORKING})
      end

      # set the status to 'failed' passing along any additional messages
      def failed(*messages)
        set_status({'status' => Operationable::Persisters::Base::STATUS_FAILED}, *messages)
      end

      # set the status to 'completed' passing along any addional messages
      def completed(*messages)
        set_status({
          'status' => Operationable::Persisters::Base::STATUS_COMPLETED,
          'message' => "Completed at #{Time.now}"
        }, *messages)
      end

      # kill the current job, setting the status to 'killed' and raising <tt>Killed</tt>
      def kill!
        set_status({
          'status' => Operationable::Persisters::Base::STATUS_KILLED,
          'message' => "Killed at #{Time.now}"
        })
        raise Killed
      end

      private

      def set_status(*args)
        self.database_status = args
        self.status = [status, {'name'  => name}, args].flatten
      end
    end
  end
end
