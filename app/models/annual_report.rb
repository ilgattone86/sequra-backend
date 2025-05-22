# == Schema Information
#
# Table name: annual_reports
#
#  id                             :integer          not null, primary key
#  from                           :date             not null
#  until                          :date             not null
#  year                           :integer          not null
#  number_of_disbursements        :integer          default("0"), not null
#  amount_disbursed_to_merchants  :float            default("0.0"), not null
#  amount_of_orders_fee           :float            default("0.0"), not null
#  number_of_monthly_fees_charged :integer          default("0"), not null
#  amount_of_monthly_fees_charged :float            default("0.0"), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
# Indexes
#
#  index_annual_reports_on_from   (from)
#  index_annual_reports_on_until  (until)
#  index_annual_reports_on_year   (year) UNIQUE
#


class AnnualReport < ApplicationRecord
  # Validations
  validates :number_of_disbursements, comparison: { greater_than_or_equal_to: 0.0 }
  validates :amount_disbursed_to_merchants, comparison: { greater_than_or_equal_to: 0.0 }
  validates :amount_of_orders_fee, comparison: { greater_than_or_equal_to: 0.0 }
  validates :number_of_monthly_fees_charged, comparison: { greater_than_or_equal_to: 0.0 }
  validates :amount_of_monthly_fees_charged, comparison: { greater_than_or_equal_to: 0.0 }
end
