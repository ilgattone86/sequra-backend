require_relative "../test_helper"

RSpec.describe Disbursement, type: :model do
  it "has associations" do
    should belong_to(:merchant).class_name("::Merchant")
    should belong_to(:monthly_fee_compliance).class_name("::MonthlyFeeCompliance").optional
    should have_many(:orders).class_name("::Order").dependent(:nullify)
  end
end
