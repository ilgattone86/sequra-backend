# == Schema Information
#
# Table name: monthly_fee_compliances
#
#  id                          :integer          not null, primary key
#  merchant_id                 :integer          not null
#  period                      :date             not null
#  minimum_monthly_fee         :float            default("0.0"), not null
#  total_commissions_generated :float            default("0.0"), not null
#  missing_amount              :float            default("0.0"), not null
#  fee_due                     :boolean          default("false"), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_monthly_fee_compliances_on_merchant_id_and_period  (merchant_id,period) UNIQUE
#

class MonthlyFeeCompliance < ApplicationRecord
  # Associations
  belongs_to :merchant, class_name: "::Merchant"

  has_many :orders, class_name: "::Order"
  has_many :disbursements, class_name: "::Disbursement"

  # Validations
  validates :minimum_monthly_fee, comparison: { greater_than_or_equal_to: 0.0 }
  validates :total_commissions_generated, comparison: { greater_than_or_equal_to: 0.0 }
  validates :missing_amount, comparison: { greater_than_or_equal_to: 0.0 }
end
