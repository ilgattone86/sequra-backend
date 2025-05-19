class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.float :amount, null: false, comment: "The amount of the order"
      t.date :order_received_at, null: false, comment: "The date of the order"
      t.references :merchant, null: false, foreign_key: true, comment: "Merchant that the order belongs to"
      t.references :disbursement, null: true, foreign_key: true, comment: "The disbursement that the order belongs to, can be null if the order is not disbursed yet"

      t.timestamps
    end
  end
end
