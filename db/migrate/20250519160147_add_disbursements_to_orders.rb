class AddDisbursementsToOrders < ActiveRecord::Migration[8.0]
  def change
    # Add the disbursement reference to the orders table
    add_reference :orders, :disbursement, foreign_key: true, null: true, comment: "The disbursement that the order belongs to, can be null if the order is not disbursed yet"
  end
end
