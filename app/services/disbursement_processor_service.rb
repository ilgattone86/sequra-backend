# frozen_string_literal: true

# Service responsible for computing disbursements for merchants on a given date.
#
# It groups orders by merchant, calculates disbursement amounts,
# and creates corresponding Disbursement records.
class DisbursementProcessorService
  # Computes disbursements for all merchants applicable on the given date.
  #
  # @param [Date] date The date to compute disbursements for.
  #
  # @return [void]
  def compute_disbursements_for(date)
    merchants_with_disbursements = disbursements_by_merchant(date)
    orders_by_merchant = orders_to_disburse_for_merchants(date)

    ::ApplicationRecord.transaction do
      orders_by_merchant.each do |merchant, orders|
        next if merchants_with_disbursements.include?(merchant.id)

        create_disbursement_for(merchant, orders, date)
      end
    end
  end

  private

  # Returns an array of merchant IDs that have disbursements for the given date.
  #
  # @param [Date] date The date to check for disbursements.
  #
  # @return [Array<Integer>]
  def disbursements_by_merchant(date)
    ::Disbursement.for_disbursement_date(date).pluck(:merchant_id)
  end

  # Returns a hash mapping merchant IDs to their eligible orders.
  #
  # @param [Date] date The date for which to fetch orders.
  #
  # @return [Hash{Merchant => Array<::Order>}]
  def orders_to_disburse_for_merchants(date)
    merchants = ::Merchant.live_before(date)
    orders_not_disbursed = ::Order.not_disbursed

    daily_orders = orders_not_disbursed.for_order_received_at(date)
                                       .joins(:merchant)
                                       .merge(merchants.daily)

    weekly_orders = orders_not_disbursed.for_order_received_in_range((date - 6.days)..date)
                                        .joins(:merchant)
                                        .merge(merchants.weekly.for_live_on_week_day(date))

    daily_orders.or(weekly_orders).includes(:merchant).group_by(&:merchant)
  end

  # Creates a disbursement record and assigns orders to it.
  #
  # If there are no orders it won't create a disbursement.
  #
  # @param [Merchant] merchant The merchant receiving the disbursement.
  # @param [Array<::Order>] orders The orders to include in the disbursement.
  # @param [Date] date The disbursement date.
  #
  # @return [::Disbursement] The created disbursement record.
  def create_disbursement_for(merchant, orders, date)
    return if orders.blank?

    total_amount = orders.sum(&:amount).round(2)
    total_commission = orders.sum(&:commission_fee).round(2)
    disbursed_amount = (total_amount - total_commission).round(2)

    disbursement = ::Disbursement.create!(
      merchant: merchant,
      disbursement_date: date,
      total_amount: total_amount,
      disbursed_amount: disbursed_amount,
      total_commission_fee: total_commission
    )

    # Update the orders that should be included in the disbursement with the ID
    ::Order.where(id: orders).update_all(disbursement_id: disbursement.id)

    disbursement
  end
end
