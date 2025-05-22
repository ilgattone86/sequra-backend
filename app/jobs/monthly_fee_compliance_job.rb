class MonthlyFeeComplianceJob < ApplicationJob
  queue_as :default

  def perform
    # I'm planning to run this the first day of each month early in the morning (like 1am)
    # to generate the monthly fee compliance resume for the previous month.
    beginning_of_previous_month = (Date.today - 1.month).beginning_of_month
    ::MonthlyFeeComplianceProcessorService.new.compute_fee_compliance_for(beginning_of_previous_month)
  end
end
