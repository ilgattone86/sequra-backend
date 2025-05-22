class AnnualReportJob < ApplicationJob
  queue_as :default

  def perform
    # I'm planning to run this the first day of each year early in the morning BUT after the monthly fee compliance job
    previous_year = Date.today.prev_year
    ::AnnualReportProcessorService.new.compute_report_for(previous_year)
  end
end
