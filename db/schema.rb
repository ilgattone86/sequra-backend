# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_19_150059) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "merchants", force: :cascade do |t|
    t.string "email", null: false, comment: "Merchant email"
    t.string "reference", null: false, comment: "Merchant reference"
    t.date "live_on", null: false, comment: "When the merchant start the business with sequra"
    t.integer "disbursement_frequency", null: false, comment: "The frequency of the disbursement"
    t.float "minimum_monthly_fee", null: false, comment: "The minimum monthly fee that the merchant has to reach"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.float "amount", null: false, comment: "The amount of the order"
    t.date "order_received_at", null: false, comment: "The date of the order"
    t.bigint "merchant_id", null: false, comment: "Merchant that the order belongs to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_orders_on_merchant_id"
  end

  add_foreign_key "orders", "merchants"
end
