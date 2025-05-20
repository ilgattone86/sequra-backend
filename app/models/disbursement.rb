# == Schema Information
#
# Table name: disbursements
#
#  id                :integer          not null, primary key
#  merchant_id       :integer          not null
#  disbursement_date :date             not null
#  total_commission  :float            default("0.0"), not null
#  total_amount      :float            default("0.0"), not null
#  disbursed_amount  :float            default("0.0"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_disbursements_on_merchant_id  (merchant_id)
#

class Disbursement < ApplicationRecord
  # Associations
  belongs_to :merchant, class_name: "::Merchant"

  has_many :orders, class_name: "::Order", dependent: :nullify
end
