# frozen_string_literal: true
# == Schema Information
#
# Table name: operations
#
#  id           :integer          not null, primary key
#  name         :string
#  initiator_id :integer
#  params       :json
#  callbacks    :json
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Operation < ActiveRecord::Base
end
