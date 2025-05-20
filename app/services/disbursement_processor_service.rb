class DisbursementProcessorService
  def compute_disbursements_for(date)
    orders_by_merchant = orders_to_disburse(date)

    ::ApplicationRecord.transaction do
      orders_by_merchant.each do |merchant_id, orders|

        total_amount = orders.sum(&:amount).round(2)
        total_commission = orders.sum(&:commission_fee).round(2)
        disbursed_amount = (total_amount - total_commission).round(2)

        disbursement = ::Disbursement.create!(disbursement_date: date,
                                              merchant_id: merchant_id,
                                              total_amount: total_amount,
                                              total_commission: total_commission,
                                              disbursed_amount: disbursed_amount)

        ::Order.where(id: orders.map(&:id)).update_all(disbursement_id: disbursement.id)
      end
    end
  end

  private

  def orders_to_disburse(date)
    merchants = ::Merchant.live_on(date)

    orders_not_disbursed = ::Order.not_disbursed

    orders_disbursables_daily = orders_not_disbursed.for_order_received_at(date)
                                                    .joins(:merchant)
                                                    .merge(merchants.daily)

    orders_disbursables_weekly = orders_not_disbursed.for_order_received_in_range(date - 6.days..date)
                                                     .joins(:merchant)
                                                     .merge(merchants.weekly.for_live_on_week_day(date))

    orders_disbursables_daily.or(orders_disbursables_weekly).group_by(&:merchant_id)
  end
end
