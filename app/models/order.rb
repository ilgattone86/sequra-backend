# == Schema Information
#
# Table name: orders
#
#  id                :integer          not null, primary key
#  amount            :float            not null
#  order_received_at :date             not null
#  merchant_id       :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  disbursement_id   :integer
#
# Indexes
#
#  index_orders_on_disbursement_id  (disbursement_id)
#  index_orders_on_merchant_id      (merchant_id)
#

class Order < ApplicationRecord
  # Associations
  belongs_to :merchant, class_name: "::Merchant"
  belongs_to :disbursement, class_name: "::Disbursement", optional: true

  # Scopes
  scope :for_merchant, ->(merchant) { where(merchant: merchant) }

  # Methods
  def compute_commission_fee
    ::CommissionFeeCalculatorService.calculate(amount)
  end
end
