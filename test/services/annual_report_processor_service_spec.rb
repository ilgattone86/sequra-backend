require_relative "../test_helper"

RSpec.describe AnnualReportProcessorService do
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

  it "should create the annual reports correctly" do
    ### Given
    ::Disbursement.create!(total_amount: 100.0,
                           disbursed_amount: 100.0,
                           total_commission_fee: 100.0,
                           disbursement_date: Date.today,
                           merchant_id: daily_merchant.id)

    ::Disbursement.create!(total_amount: 2.0,
                           disbursed_amount: 2.0,
                           total_commission_fee: 2.0,
                           disbursement_date: Date.tomorrow,
                           merchant_id: weekly_merchant.id)

    ::MonthlyFeeCompliance.create!(fee_due: true,
                                   period: Date.today,
                                   total_amount: 100.0,
                                   missing_amount: 10.0,
                                   merchant: daily_merchant,
                                   minimum_monthly_fee: 10.0,
                                   total_commissions_fees_generated: 100.0)

    ::MonthlyFeeCompliance.create!(fee_due: true,
                                   period: Date.today,
                                   total_amount: 2.0,
                                   missing_amount: 2.0,
                                   merchant: weekly_merchant,
                                   minimum_monthly_fee: 2.0,
                                   total_commissions_fees_generated: 2.0)

    reports_before = ::AnnualReport.count

    ### When
    report = ::AnnualReportProcessorService.new.compute_report_for(Date.today)
    reports_after = ::AnnualReport.count


    ### Then
    expect(reports_before).to eq(0)
    expect(reports_after).to eq(1)

    expect(report).not_to be_nil
    expect(report.number_of_disbursements).to eq(2)
    expect(report.amount_disbursed_to_merchants).to eq(102.0)
    expect(report.number_of_monthly_fees_charged).to eq(2)
    expect(report.amount_of_monthly_fees_charged).to eq(12.0)
    expect(report.amount_of_orders_commission_fee).to eq(102.0)
  end

  it "should exclude from the report the disbursement that belong to another year" do
    ### Given
    ::Disbursement.create!(total_amount: 100.0,
                           total_commission_fee: 100.0,
                           disbursed_amount: 100.0,
                           disbursement_date: Date.today,
                           merchant_id: daily_merchant.id)

    ::Disbursement.create!(total_amount: 2.0,
                           total_commission_fee: 2.0,
                           disbursed_amount: 2.0,
                           disbursement_date: Date.tomorrow + 1.year,
                           merchant_id: weekly_merchant.id)

    ::MonthlyFeeCompliance.create!(fee_due: true,
                                   period: Date.today,
                                   total_amount: 100.0,
                                   missing_amount: 10.0,
                                   merchant: daily_merchant,
                                   minimum_monthly_fee: 10.0,
                                   total_commissions_fees_generated: 100.0)

    ::MonthlyFeeCompliance.create!(fee_due: true,
                                   period: Date.today,
                                   total_amount: 2.0,
                                   missing_amount: 2.0,
                                   merchant: weekly_merchant,
                                   minimum_monthly_fee: 2.0,
                                   total_commissions_fees_generated: 2.0)

    reports_before = ::AnnualReport.count

    ### When
    report = ::AnnualReportProcessorService.new.compute_report_for(Date.today)
    reports_after = ::AnnualReport.count


    ### Then
    expect(reports_before).to eq(0)
    expect(reports_after).to eq(1)

    expect(report).not_to be_nil
    expect(report.number_of_disbursements).to eq(1)
    expect(report.amount_disbursed_to_merchants).to eq(100.0)
    expect(report.number_of_monthly_fees_charged).to eq(2)
    expect(report.amount_of_monthly_fees_charged).to eq(12.0)
    expect(report.amount_of_orders_commission_fee).to eq(102.0)
  end

  it "should exclude from the report the monthly fee that belong to another year" do
    ### Given
    ::Disbursement.create!(total_amount: 100.0,
                           total_commission_fee: 100.0,
                           disbursed_amount: 100.0,
                           disbursement_date: Date.today,
                           merchant_id: daily_merchant.id)

    ::Disbursement.create!(total_amount: 2.0,
                           total_commission_fee: 2.0,
                           disbursed_amount: 2.0,
                           disbursement_date: Date.today,
                           merchant_id: weekly_merchant.id)

    ::MonthlyFeeCompliance.create!(fee_due: true,
                                   period: Date.today,
                                   total_amount: 100.0,
                                   missing_amount: 10.0,
                                   merchant: daily_merchant,
                                   minimum_monthly_fee: 10.0,
                                   total_commissions_fees_generated: 100.0)

    ::MonthlyFeeCompliance.create!(fee_due: true,
                                   period: Date.today + 1.year,
                                   total_amount: 2.0,
                                   missing_amount: 2.0,
                                   merchant: weekly_merchant,
                                   minimum_monthly_fee: 2.0,
                                   total_commissions_fees_generated: 2.0)

    reports_before = ::AnnualReport.count

    ### When
    report = ::AnnualReportProcessorService.new.compute_report_for(Date.today)
    reports_after = ::AnnualReport.count


    ### Then
    expect(reports_before).to eq(0)
    expect(reports_after).to eq(1)

    expect(report).not_to be_nil
    expect(report.number_of_disbursements).to eq(2)
    expect(report.amount_disbursed_to_merchants).to eq(102.0)
    expect(report.number_of_monthly_fees_charged).to eq(1)
    expect(report.amount_of_monthly_fees_charged).to eq(10.0)
    expect(report.amount_of_orders_commission_fee).to eq(100.0)
  end

  it "should exclude from the report the monthly fee that is not fee due" do
    ### Given
    ::Disbursement.create!(total_amount: 100.0,
                           total_commission_fee: 100.0,
                           disbursed_amount: 100.0,
                           disbursement_date: Date.today,
                           merchant_id: daily_merchant.id)

    ::Disbursement.create!(total_amount: 2.0,
                           total_commission_fee: 2.0,
                           disbursed_amount: 2.0,
                           disbursement_date: Date.today,
                           merchant_id: weekly_merchant.id)

    ::MonthlyFeeCompliance.create!(fee_due: true,
                                   period: Date.today,
                                   total_amount: 100.0,
                                   missing_amount: 10.0,
                                   merchant: daily_merchant,
                                   minimum_monthly_fee: 10.0,
                                   total_commissions_fees_generated: 100.0)

    ::MonthlyFeeCompliance.create!(fee_due: false,
                                   period: Date.today,
                                   total_amount: 2.0,
                                   missing_amount: 2.0,
                                   merchant: weekly_merchant,
                                   minimum_monthly_fee: 2.0,
                                   total_commissions_fees_generated: 2.0)

    reports_before = ::AnnualReport.count

    ### When
    report = ::AnnualReportProcessorService.new.compute_report_for(Date.today)
    reports_after = ::AnnualReport.count


    ### Then
    expect(reports_before).to eq(0)
    expect(reports_after).to eq(1)

    expect(report).not_to be_nil
    expect(report.number_of_disbursements).to eq(2)
    expect(report.amount_disbursed_to_merchants).to eq(102.0)
    expect(report.number_of_monthly_fees_charged).to eq(1)
    expect(report.amount_of_monthly_fees_charged).to eq(10.0)
    expect(report.amount_of_orders_commission_fee).to eq(102.0)
  end
end
