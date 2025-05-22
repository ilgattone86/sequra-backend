class ModifyCommissionColumnName < ActiveRecord::Migration[8.0]
  def change
    rename_column :disbursements, :total_commission, :total_commission_fee
    rename_column :annual_reports, :amount_of_orders_fee, :amount_of_orders_commission_fee
    rename_column :monthly_fee_compliances, :total_commissions_generated, :total_commissions_fees_generated
  end
end
