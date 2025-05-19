class CreateMerchants < ActiveRecord::Migration[8.0]
  def change
    create_table :merchants do |t|
      t.string :email, null: false, comment: "Merchant email"
      t.string :reference, null: false, comment: "Merchant reference"
      t.date :live_on, null: false, comment: "When the merchant start the business with sequra"
      t.integer :disbursement_frequency, null: false, comment: "The frequency of the disbursement"
      t.float :minimum_monthly_fee, null: false, comment: "The minimum monthly fee that the merchant has to reach"

      t.timestamps
    end
  end
end
