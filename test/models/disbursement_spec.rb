require_relative "../test_helper"

RSpec.describe Disbursement, type: :model do
  it "has associations" do
    should belong_to(:merchant).class_name("::Merchant")
    should have_many(:orders).class_name("::Order").dependent(:nullify)
  end

  describe "scopes" do
    it "has a for_period scope" do
      range = Date.today..Date.tomorrow
      expected_query = described_class.where(disbursement_date: range)
      expect(described_class.for_period(range).to_sql).to eq(expected_query.to_sql)
    end

    it "has a for_disbursement_date scope" do
      today = Date.today
      expected_query = described_class.where(disbursement_date: today)
      expect(described_class.for_disbursement_date(today).to_sql).to eq(expected_query.to_sql)
    end
  end
end
