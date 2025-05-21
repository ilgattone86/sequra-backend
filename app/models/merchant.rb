# == Schema Information
#
# Table name: merchants
#
#  id                     :integer          not null, primary key
#  email                  :string           not null
#  reference              :string           not null
#  live_on                :date             not null
#  disbursement_frequency :integer          not null
#  minimum_monthly_fee    :float            not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Merchant < ApplicationRecord
  # Associations
  has_many :orders, class_name: "::Order", dependent: :destroy
  has_many :disbursements, class_name: "::Disbursement", dependent: :destroy
  has_many :monthly_fee_compliances, class_name: "::MonthlyFeeCompliance", dependent: :destroy

  # Enums
  enum :disbursement_frequency, [ :daily, :weekly ]

  # Scopes
  scope :live_before, ->(date) { where(live_on: ..date) }
  scope :for_live_on_week_day, ->(date) { where("EXTRACT(DOW FROM live_on) = ?", date.wday) }
end
