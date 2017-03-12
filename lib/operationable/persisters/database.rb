# frozen_string_literal: true
module Operationable
  module Persisters
    module Database
      def self.create(q_options, props)
        date = Time.zone.now.to_date

        ::OperationCallback.create(
          q_options: q_options,
          props: props,
          attempts: 0,
          week: props[:week] || date.cweek,
          year: props[:year] || date.year,
          status: Operationable::Persisters::Base::STATUS_INIT
        )
      end

      def notify_database
        self.database_status = [{status: Operationable::Persisters::Base::STATUS_QUEUED}]
      end

      def op_cb_id
        arguments.first[:q_options][:op_cb_id]
      end

      def database_status
        ::OperationCallback.find(op_cb_id)
      end

      def database_status=(new_status)
        ::OperationCallback.find(op_cb_id).update(
          new_status.reduce({uuid: uuid}){ |acc, o| acc.merge(o) }
        )
      end
    end
  end
end
