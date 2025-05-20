class CreateDisbursements < ActiveRecord::Migration[8.0]
  def change
    create_table :disbursements do |t|
      t.references :merchant, foreign_key: true, null: false, comment: "Merchant that the disbursement belongs to"

      t.date :disbursement_date, null: false, comment: "The date of the disbursement"
      t.float :total_commission, null: false, default: 0.0, comment: "The sum of the commission fees of all the orders"
      t.float :total_amount, null: false, default: 0.0, comment: "The total amount of the disbursement, it is the sum of all the orders amount"
      t.float :disbursed_amount, null: false, default: 0.0, comment: "The amount that the merchant will receive after the commission fees are deducted"

      t.timestamps
    end
  end
end
