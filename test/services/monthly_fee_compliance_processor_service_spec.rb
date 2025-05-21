# require_relative "../test_helper"
#
# RSpec.describe MonthlyFeeComplianceProcessorService do
#   let(:daily_merchant) do
#     ::Merchant.create!(email: "a@a.com",
#                        minimum_monthly_fee: 10.0,
#                        reference: "daily_merchant",
#                        live_on: Date.new(2023, 1, 1),
#                        disbursement_frequency: :daily)
#   end
#
#   let(:weekly_merchant) do
#     ::Merchant.create!(email: "a@a.com",
#                        minimum_monthly_fee: 10.0,
#                        reference: "weekly_merchant",
#                        live_on: Date.new(2023, 1, 1),
#                        disbursement_frequency: :weekly)
#   end
#
#   it "should create the correct monthly fee for merchants" do
#     ### Given
#     order1 = ::Order.create!(amount: 100.0, order_received_at: Date.new(2023, 1, 1), merchant: daily_merchant)
#     order2 = ::Order.create!(amount: 200.0, order_received_at: Date.new(2023, 1, 1), merchant: daily_merchant)
#     daily_merchant_total_commission = (order1.commission_fee + order2.commission_fee).round(2)
#
#     order3 = ::Order.create!(amount: 10.0, order_received_at: Date.new(2023, 1, 1), merchant: weekly_merchant)
#     order4 = ::Order.create!(amount: 200.0, order_received_at: Date.new(2023, 1, 1), merchant: weekly_merchant)
#     weekly_merchant_total_commission = (order3.commission_fee + order4.commission_fee).round(2)
#
#     disbursements_before = ::Disbursement.count
#
#     ### When
#     ::MonthlyFeeComplianceProcessorService.new.compute_fee_compliance_for(daily_merchant.live_on)
#     disbursements_after = ::Disbursement.count
#
#     daily_merchant_disbursement = ::Disbursement.where(merchant: daily_merchant).first
#     weekly_merchant_disbursement = ::Disbursement.where(merchant: weekly_merchant).first
#
#
#     ### Then
#     expect(disbursements_before).to eq(0)
#     expect(disbursements_after).to eq(2)
#
#     expect(daily_merchant_disbursement.orders).to include(order1, order2)
#     expect(daily_merchant_disbursement.total_amount).to eq(300.0)
#     expect(daily_merchant_disbursement.total_commission).to eq(daily_merchant_total_commission)
#     expect(daily_merchant_disbursement.disbursed_amount).to eq(300.0 - daily_merchant_total_commission)
#
#     expect(weekly_merchant_disbursement.orders).to include(order3, order4)
#     expect(weekly_merchant_disbursement.total_amount).to eq(210.0)
#     expect(weekly_merchant_disbursement.total_commission).to eq(weekly_merchant_total_commission)
#     expect(weekly_merchant_disbursement.disbursed_amount).to eq(210.0 - weekly_merchant_total_commission)
#   end
#
#   it "should exclude the order 3 if it is in another date" do
#     ### Given
#     order1 = ::Order.create!(amount: 100.0, order_received_at: Date.new(2023, 1, 1), merchant: daily_merchant)
#     order2 = ::Order.create!(amount: 200.0, order_received_at: Date.new(2023, 1, 1), merchant: daily_merchant)
#     order3 = ::Order.create!(amount: 200.0, order_received_at: Date.new(2023, 1, 2), merchant: daily_merchant)
#     daily_merchant_total_commission = (order1.commission_fee + order2.commission_fee).round(2)
#
#     ### When
#     ::DisbursementProcessorService.new.compute_disbursements_for(daily_merchant.live_on)
#     daily_merchant_disbursement = ::Disbursement.where(merchant: daily_merchant).first
#
#     ### Then
#     expect(daily_merchant_disbursement.orders).to include(order1, order2)
#     expect(daily_merchant_disbursement.orders).not_to include(order3)
#
#     expect(daily_merchant_disbursement.total_amount).to eq(300.0)
#     expect(daily_merchant_disbursement.total_commission).to eq(daily_merchant_total_commission)
#     expect(daily_merchant_disbursement.disbursed_amount).to eq(300.0 - daily_merchant_total_commission)
#   end
#
#   it "should include the right orders for the weekly merchant" do
#     ### Given
#     order1 = ::Order.create!(amount: 100.0, order_received_at: Date.new(2023, 1, 1), merchant: weekly_merchant)
#     order2 = ::Order.create!(amount: 200.0, order_received_at: Date.new(2023, 1, 2), merchant: weekly_merchant)
#     order3 = ::Order.create!(amount: 300.0, order_received_at: Date.new(2023, 1, 3), merchant: weekly_merchant)
#     order4 = ::Order.create!(amount: 400.0, order_received_at: Date.new(2023, 1, 4), merchant: weekly_merchant)
#     order5 = ::Order.create!(amount: 500.0, order_received_at: Date.new(2023, 1, 5), merchant: weekly_merchant)
#     order6 = ::Order.create!(amount: 600.0, order_received_at: Date.new(2023, 1, 6), merchant: weekly_merchant)
#     order7 = ::Order.create!(amount: 700.0, order_received_at: Date.new(2023, 1, 7), merchant: weekly_merchant)
#     order8 = ::Order.create!(amount: 800.0, order_received_at: Date.new(2023, 1, 8), merchant: weekly_merchant)
#
#     orders = [ order2, order3, order4, order5, order6, order7, order8 ]
#
#     total_amount = orders.sum(&:amount).round(2)
#     total_commission = orders.sum(&:commission_fee).round(2)
#     disbursed_amount = (total_amount - total_commission).round(2)
#
#     ### When
#     ::DisbursementProcessorService.new.compute_disbursements_for(order8.order_received_at)
#     weekly_merchant_disbursement = ::Disbursement.where(merchant: weekly_merchant).first
#
#     ### Then
#     expect(weekly_merchant_disbursement.orders).to match_array(orders)
#     expect(weekly_merchant_disbursement.orders).not_to include(order1)
#
#     expect(weekly_merchant_disbursement.total_amount).to eq(total_amount)
#     expect(weekly_merchant_disbursement.total_commission).to eq(total_commission)
#     expect(weekly_merchant_disbursement.disbursed_amount).to eq(disbursed_amount)
#   end
# end
