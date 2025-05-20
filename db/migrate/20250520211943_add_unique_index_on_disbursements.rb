class AddUniqueIndexOnDisbursements < ActiveRecord::Migration[8.0]
  def change
    remove_index :disbursements, name: "index_disbursements_on_merchant_id"
    add_index :disbursements, %i[merchant_id disbursement_date], unique: true
  end
end
