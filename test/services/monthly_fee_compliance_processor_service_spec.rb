require_relative "../test_helper"

RSpec.describe MonthlyFeeComplianceProcessorService do
  let!(:daily_merchant) do
    ::Merchant.create!(email: "a@a.com",
                       minimum_monthly_fee: 10.0,
                       reference: "daily_merchant",
                       live_on: Date.new(2023, 1, 1),
                       disbursement_frequency: :daily)
  end

  let!(:weekly_merchant) do
    ::Merchant.create!(email: "a@a.com",
                       minimum_monthly_fee: 10.0,
                       reference: "weekly_merchant",
                       live_on: Date.new(2023, 1, 1),
                       disbursement_frequency: :weekly)
  end

  it "should create the correct monthly fee for merchants" do
    ### Given
    order1 = ::Order.create!(amount: 100.0, order_received_at: Date.new(2023, 1, 1), merchant: daily_merchant)
    order2 = ::Order.create!(amount: 200.0, order_received_at: Date.new(2023, 1, 1), merchant: daily_merchant)
    daily_merchant_total_commission = (order1.commission_fee + order2.commission_fee).round(2)

    order3 = ::Order.create!(amount: 10.0, order_received_at: Date.new(2023, 1, 1), merchant: weekly_merchant)
    order4 = ::Order.create!(amount: 200.0, order_received_at: Date.new(2023, 1, 1), merchant: weekly_merchant)
    weekly_merchant_total_commission = (order3.commission_fee + order4.commission_fee).round(2)

    compliances_before = ::MonthlyFeeCompliance.count

    ### When
    ::MonthlyFeeComplianceProcessorService.new.compute_fee_compliance_for(daily_merchant.live_on)
    compliances_after = ::MonthlyFeeCompliance.count

    daily_merchant_compliance = ::MonthlyFeeCompliance.where(merchant: daily_merchant).first
    weekly_merchant_compliance = ::MonthlyFeeCompliance.where(merchant: weekly_merchant).first


    ### Then
    expect(compliances_before).to eq(0)
    expect(compliances_after).to eq(2)

    expect(daily_merchant_compliance.orders).to match_array([ order1, order2 ])
    expect(daily_merchant_compliance.total_amount).to eq(300.0)
    expect(daily_merchant_compliance.minimum_monthly_fee).to eq(10.0)
    expect(daily_merchant_compliance.total_commissions_fees_generated).to eq(daily_merchant_total_commission)
    expect(daily_merchant_compliance.missing_amount).to eq(7.15)
    expect(daily_merchant_compliance.fee_due).to be(true)

    expect(weekly_merchant_compliance.orders).to match_array([ order3, order4 ])
    expect(weekly_merchant_compliance.total_amount).to eq(210.0)
    expect(weekly_merchant_compliance.total_commissions_fees_generated).to eq(weekly_merchant_total_commission)
    expect(weekly_merchant_compliance.minimum_monthly_fee).to eq(10.0)
    expect(weekly_merchant_compliance.missing_amount).to eq(8.0)
    expect(weekly_merchant_compliance.fee_due).to be(true)
  end

  it "should set the fee due to false if the merchant has a minimum monthly fee of zero" do
    ### Given
    daily_merchant.update!(minimum_monthly_fee: 0)

    ::Order.create!(amount: 100.0, order_received_at: Date.new(2023, 1, 1), merchant: daily_merchant)
    ::Order.create!(amount: 200.0, order_received_at: Date.new(2023, 1, 1), merchant: daily_merchant)

    ### When
    ::MonthlyFeeComplianceProcessorService.new.compute_fee_compliance_for(daily_merchant.live_on)

    daily_merchant_compliance = ::MonthlyFeeCompliance.where(merchant: daily_merchant).first

    ### Then
    expect(daily_merchant_compliance.fee_due).to be(false)
  end

  it "should not create a compliance for a merchant that is not live yet" do
    ### Given
    daily_merchant.update!(live_on: weekly_merchant.live_on.beginning_of_month + 1.month)

    ::Order.create!(amount: 100.0, order_received_at: Date.new(2023, 1, 1), merchant: daily_merchant)
    ::Order.create!(amount: 200.0, order_received_at: Date.new(2023, 1, 1), merchant: daily_merchant)

    ### When
    ::MonthlyFeeComplianceProcessorService.new.compute_fee_compliance_for(weekly_merchant.live_on)

    daily_merchant_compliance = ::MonthlyFeeCompliance.where(merchant: daily_merchant).first

    ### Then
    expect(daily_merchant_compliance).to be_nil
  end

  it "should not add an order that belongs to another month" do
    ### Given
    next_month = daily_merchant.live_on.beginning_of_month + 1.month

    order1 = ::Order.create!(amount: 100.0, order_received_at: Date.new(2023, 1, 1), merchant: daily_merchant)
    order2 = ::Order.create!(amount: 200.0, order_received_at: Date.new(2023, 1, 1), merchant: daily_merchant)
    order3 = ::Order.create!(amount: 200.0, order_received_at: next_month, merchant: daily_merchant)
    daily_merchant_total_commission = (order1.commission_fee + order2.commission_fee).round(2)

    ### When
    ::MonthlyFeeComplianceProcessorService.new.compute_fee_compliance_for(daily_merchant.live_on)

    daily_merchant_compliance = ::MonthlyFeeCompliance.where(merchant: daily_merchant).first

    ### Then
    expect(daily_merchant_compliance.fee_due).to be(true)
    expect(daily_merchant_compliance.total_amount).to eq(300.0)
    expect(daily_merchant_compliance.missing_amount).to eq(7.15)
    expect(daily_merchant_compliance.orders).not_to include(order3)
    expect(daily_merchant_compliance.minimum_monthly_fee).to eq(10.0)
    expect(daily_merchant_compliance.orders).to match_array([ order1, order2 ])
    expect(daily_merchant_compliance.total_commissions_fees_generated).to eq(daily_merchant_total_commission)
  end
end
