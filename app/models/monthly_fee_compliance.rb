# == Schema Information
#
# Table name: monthly_fee_compliances
#
#  id                               :integer          not null, primary key
#  merchant_id                      :integer          not null
#  period                           :date             not null
#  minimum_monthly_fee              :float            default("0.0"), not null
#  total_commissions_fees_generated :float            default("0.0"), not null
#  missing_amount                   :float            default("0.0"), not null
#  fee_due                          :boolean          default("false"), not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  total_amount                     :float            default("0.0"), not null
#
# Indexes
#
#  index_monthly_fee_compliances_on_merchant_id_and_period  (merchant_id,period) UNIQUE
#

class MonthlyFeeCompliance < ApplicationRecord
  # Associations
  belongs_to :merchant, class_name: "::Merchant"

  has_many :orders, class_name: "::Order", dependent: :nullify

  # Validations
  validates :minimum_monthly_fee, comparison: { greater_than_or_equal_to: 0.0 }
  validates :total_commissions_fees_generated, comparison: { greater_than_or_equal_to: 0.0 }
  validates :missing_amount, comparison: { greater_than_or_equal_to: 0.0 }
  validates :total_amount, numericality: { greater_than_or_equal_to: 0.0 }
  validate :merchant_has_already_a_monthly_fee

  # Scopes
  scope :for_merchant, ->(merchant) { where(merchant: merchant) }
  scope :for_year_and_month, ->(year, month) {
    where("EXTRACT(YEAR FROM period) = ? AND EXTRACT(MONTH FROM period) = ?", year, month)
  }
  scope :for_year, ->(year) { where("EXTRACT(YEAR FROM period) = ?", year) }
  scope :for_month, ->(month) { where("EXTRACT(MONTH FROM period) = ?", month) }
  scope :for_fee_due, ->(fee_due) { where(fee_due: fee_due) }

  private

  # Validates if the merchant already has a monthly fee compliance for the same month.
  #
  # @return [void]
  def merchant_has_already_a_monthly_fee
    return if ::MonthlyFeeCompliance.where.not(id: id).for_merchant(merchant).for_year_and_month(period.year, period.month).blank?

    errors.add("There is already a monthly fee compliance for this merchant in this month")
  end
end
