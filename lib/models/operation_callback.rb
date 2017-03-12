# == Schema Information
#
# Table name: operation_callbacks
#
#  id         :integer          not null, primary key
#  status     :string
#  message    :text
#  uuid       :string
#  q_options  :json
#  props      :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OperationCallback < ActiveRecord::Base
end
