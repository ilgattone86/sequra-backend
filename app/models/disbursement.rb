# == Schema Information
#
# Table name: disbursements
#
#  id                   :integer          not null, primary key
#  merchant_id          :integer          not null
#  disbursement_date    :date             not null
#  total_commission_fee :float            default("0.0"), not null
#  total_amount         :float            default("0.0"), not null
#  disbursed_amount     :float            default("0.0"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_disbursements_on_merchant_id_and_disbursement_date  (merchant_id,disbursement_date) UNIQUE
#

class Disbursement < ApplicationRecord
  # Associations
  belongs_to :merchant, class_name: "::Merchant"

  has_many :orders, class_name: "::Order", dependent: :nullify

  # Validations
  validates :total_amount, comparison: { greater_than_or_equal_to: 0.0 }
  validates :disbursed_amount, comparison: { greater_than_or_equal_to: 0.0 }
  validates :total_commission_fee, comparison: { greater_than_or_equal_to: 0.0 }

  # Scopes
  scope :for_period, ->(period) { where(disbursement_date: period) }
end
