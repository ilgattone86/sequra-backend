# frozen_string_literal: true

# Service that computes annual reports for sequra.
class AnnualReportProcessorService
  # Computes the annual report for the given date's year.
  #
  # @param date [Date] the date to compute the report for
  #
  # @return [void]
  def compute_report_for(date)
    raise "The report for the year #{date.year} already exists" if ::AnnualReport.exists?(year: date.year)

    year_range = date.beginning_of_year..date.end_of_year

    disbursements_of_the_year = ::Disbursement.for_period(year_range)
    monthly_fee_compliances_of_the_year = ::MonthlyFeeCompliance.for_year(date.year)

    number_of_disbursements = disbursements_of_the_year.count
    amount_disbursed_to_merchants = disbursements_of_the_year.sum(:disbursed_amount)
    amount_of_orders_fee = monthly_fee_compliances_of_the_year.sum(:total_commissions_generated)
    number_of_monthly_fees_charged = monthly_fee_compliances_of_the_year.for_fee_due(true).count
    amount_of_monthly_fees_charged = monthly_fee_compliances_of_the_year.for_fee_due(true).sum(:missing_amount)

    ::AnnualReport.create!(year: date.year,
                           from: year_range.begin,
                           until: year_range.end,
                           amount_of_orders_fee: amount_of_orders_fee,
                           number_of_disbursements: number_of_disbursements,
                           amount_disbursed_to_merchants: amount_disbursed_to_merchants,
                           number_of_monthly_fees_charged: number_of_monthly_fees_charged,
                           amount_of_monthly_fees_charged: amount_of_monthly_fees_charged)
  end
end
