# frozen_string_literal: true

# Service that calculates monthly fee compliance for merchants.
# It creates a MonthlyFeeCompliance record for each merchant based on their orders in the given month.
class MonthlyFeeComplianceProcessorService
  # Computes the monthly fee compliance for all merchants for the given date's month.
  #
  # @param date [Date] any date within the target month
  #
  # @return [void]
  def compute_fee_compliance_for(date)
    period_range = date.beginning_of_month..date.end_of_month

    merchants = ::Merchant.live_before(period_range.end)
    orders_by_merchant_id = fetch_orders_grouped_by_merchant(merchants, period_range)
    compliances_by_merchant = fetch_compliances_grouped_by_merchant(merchants, date)

    ::ApplicationRecord.transaction do
      merchants.each do |merchant|
        next if compliances_by_merchant[merchant.id].present?

        merchant_orders = orders_by_merchant_id[merchant.id] || []
        create_compliance_for(merchant, merchant_orders, period_range.begin)
      end
    end
  end

  private

  # Fetches and groups orders by merchant within the given range.
  #
  # @param merchants [ActiveRecord::Relation<::Merchant>] merchants to fetch orders for
  # @param range [Range<Date>] the date range to filter orders
  #
  # @return [Hash{Integer => Array<::Order>}] orders grouped by merchant ID
  def fetch_orders_grouped_by_merchant(merchants, range)
    ::Order.for_order_received_in_range(range)
           .joins(:merchant)
           .merge(::Merchant.where(id: merchants))
           .group_by(&:merchant_id)
  end

  # Fetches and groups monthly fee compliances by merchant of the date
  #
  # @param merchants [ActiveRecord::Relation<::Merchant>] merchants to fetch compliances for
  # @param date [Date] the date of the month to fetch compliances
  #
  # @return [Hash{Integer => Array<::Order>}] orders grouped by merchant ID
  def fetch_compliances_grouped_by_merchant(merchants, date)
    ::MonthlyFeeCompliance.for_merchant(merchants)
                          .for_year_and_month(date.year, date.month)
                          .group_by(&:merchant_id)
  end

  # Builds a MonthlyFeeCompliance record from merchant and their orders.
  #
  # @param merchant [::Merchant] the merchant to build compliance for
  # @param orders [Array<::Order>] the merchant's orders in the period
  # @param period_date [Date] the first day of the target month
  #
  # @return [::MonthlyFeeCompliance] unsaved compliance record
  def create_compliance_for(merchant, orders, period_date)
    total_amount = orders.sum(&:amount).round(2)
    total_commission = orders.sum(&:commission_fee).round(2)
    minimum_fee = merchant.minimum_monthly_fee.round(2)
    missing_amount = ([ minimum_fee - total_commission, 0 ].max).round(2)

    compliance = ::MonthlyFeeCompliance.create!(
      fee_due: total_commission < minimum_fee,
      merchant: merchant,
      period: period_date,
      total_amount: total_amount,
      missing_amount: missing_amount,
      minimum_monthly_fee: minimum_fee,
      total_commissions_generated: total_commission,
    )

    # Update the orders that should be included in the compliance with the ID
    ::Order.where(id: orders).update_all(monthly_fee_compliance_id: compliance.id)

    compliance
  end
end
