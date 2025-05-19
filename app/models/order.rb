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
#
# Indexes
#
#  index_orders_on_merchant_id  (merchant_id)
#

class Order < ApplicationRecord
  # Associations
  belongs_to :merchant, class_name: "::Merchant"
end
