# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'csv'

def seed_merchants
  merchants = []
  ::CSV.foreach('db/seeds/merchants.csv', headers: true, col_sep: ';') do |row|
    merchants << { email: row['email'],
                   reference: row['reference'],
                   live_on: Date.parse(row['live_on']),
                   minimum_monthly_fee: row['minimum_monthly_fee'].to_f.round(2),
                   disbursement_frequency: row['disbursement_frequency'] == 'DAILY' ? 0 : 1 }
  end
  ::Merchant.insert_all!(merchants)
end

def seed_orders
  merchants_by_reference = ::Merchant.all.index_by(&:reference)

  orders = []
  ::CSV.foreach('db/seeds/orders.csv', headers: true, col_sep: ';') do |row|
    merchant = merchants_by_reference[row['merchant_reference']]
    orders << { merchant_id: merchant.id,
                amount: row['amount'].to_f.round(2),
                order_received_at: Date.parse(row['created_at']) }
  end
  ::Order.insert_all!(orders)
end

# The order here is important
seed_merchants
seed_orders
