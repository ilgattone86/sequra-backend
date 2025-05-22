class DailyDisbursementsJob < ApplicationJob
  queue_as :default

  def perform
    # I'm planning to run this every day early in the morning (like 2am) to generate disbursements of the past day
    ::DisbursementProcessorService.new.compute_disbursements_for(Date.yesterday)
  end
end
