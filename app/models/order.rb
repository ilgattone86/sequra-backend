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
#  index_orders_on_disbursement_id    (disbursement_id)
#  index_orders_on_merchant_id        (merchant_id)
#  index_orders_on_order_received_at  (order_received_at)
#

class Order < ApplicationRecord
  # Associations
  belongs_to :merchant, class_name: "::Merchant"
  belongs_to :disbursement, class_name: "::Disbursement", optional: true

  # Scopes
  scope :for_merchant, ->(merchant) { where(merchant: merchant) }
  scope :disbursed, -> { where.not(disbursement: nil) }
  scope :not_disbursed, -> { where(disbursement: nil) }
  scope :for_order_received_at, ->(date) { where(order_received_at: date) }
  scope :for_order_received_in_range, ->(date_range) { where(order_received_at: date_range) }
  scope :for_order_received_between, ->(from, to) { for_order_received_in_range(from..to) }

  # Methods
  def commission_fee
    ::CommissionFeeCalculatorService.calculate(amount)
  end
end
