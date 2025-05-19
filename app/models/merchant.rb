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

  # Enums
  enum :disbursement_frequency, [ :daily, :weekly ]
end
