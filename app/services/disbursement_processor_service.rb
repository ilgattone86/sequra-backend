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
    merchants = disbursable_merchants(date)
    orders_by_merchant = orders_to_disburse_for_merchants(merchants, date)

    ::ApplicationRecord.transaction do
      merchants.each do |merchant|
        orders = orders_by_merchant[merchant.id] || []
        create_disbursement_for(merchant, orders, date)
      end
    end
  end

  private

  # Returns the list of merchants that should be disbursed on the given date.
  #
  # @param [Date] date The date to check eligibility.
  #
  # @return [ActiveRecord::Relation<::Merchant>]
  def disbursable_merchants(date)
    ::Merchant.live_before(date).daily.or(
      ::Merchant.live_before(date).weekly.for_live_on_week_day(date)
    )
  end

  # Returns a hash mapping merchant IDs to their eligible orders.
  #
  # @param [ActiveRecord::Relation<::Merchant>] merchants The merchants to include.
  # @param [Date] date The date for which to fetch orders.
  #
  # @return [Hash{Integer => Array<::Order>}]
  def orders_to_disburse_for_merchants(merchants, date)
    orders_not_disbursed = ::Order.not_disbursed

    daily_orders = orders_not_disbursed.for_order_received_at(date)
                                       .joins(:merchant)
                                       .merge(::Merchant.where(id: merchants).daily)

    weekly_orders = orders_not_disbursed.for_order_received_in_range((date - 6.days)..date)
                                        .joins(:merchant)
                                        .merge(::Merchant.where(id: merchants).weekly)

    daily_orders.or(weekly_orders).group_by(&:merchant_id)
  end

  # Creates a disbursement record and assigns orders to it.
  #
  # @param [::Merchant] merchant The merchant receiving the disbursement.
  # @param [Array<::Order>] orders The orders to include in the disbursement.
  # @param [Date] date The disbursement date.
  #
  # @return [::Disbursement] The created disbursement record.
  def create_disbursement_for(merchant, orders, date)
    total_amount = orders.sum(&:amount).round(2)
    total_commission = orders.sum(&:commission_fee).round(2)
    disbursed_amount = (total_amount - total_commission).round(2)

    disbursement = ::Disbursement.create!(
      disbursement_date: date,
      merchant: merchant,
      total_amount: total_amount,
      total_commission: total_commission,
      disbursed_amount: disbursed_amount
    )

    # Update the orders that should be included in the disbursement with the ID
    ::Order.where(id: orders).update_all(disbursement_id: disbursement.id)

    disbursement
  end
end
