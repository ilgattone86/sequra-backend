class CreateAnnualReportsTable < ActiveRecord::Migration[8.0]
  def change
    create_table :annual_reports do |t|
      t.date :from, null: false, index: true, comment: "When the report starts"
      t.date :until, null: false, index: true, comment: "When the report ends"

      t.integer :year, null: false, index: { unique: true }, comment: "The year of the report, only one report per year is allowed"

      t.integer :number_of_disbursements, null: false, default: 0, comment: "Total number of disbursements in the period"

      t.float :amount_disbursed_to_merchants, null: false, default: 0, comment: "Total amount disbursed to merchants in the period"
      t.float :amount_of_orders_fee, null: false, default: 0, comment: "Total amount of orders fee in the period"

      t.integer :number_of_monthly_fees_charged, null: false, default: 0, comment: "How many monthly fees were charged in the period"
      t.float :amount_of_monthly_fees_charged, null: false, default: 0, comment: "Total amount of monthly fees in the period"

      t.timestamps
    end
  end
end
