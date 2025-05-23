require_relative "../test_helper"

RSpec.describe MonthlyFeeCompliance, type: :model do
  it "has associations" do
    should belong_to(:merchant).class_name("::Merchant").without_validating_presence
    should have_many(:orders).class_name("::Order").dependent(:nullify).without_validating_presence
  end

  describe "scopes" do
    it "has a for_merchant scope" do
      expected_query = described_class.where(merchant: 1)
      expect(described_class.for_merchant(1).to_sql).to eq(expected_query.to_sql)
    end

    it "has a for_year_and_month scope" do
      today = Date.today
      expected_query = described_class.where("EXTRACT(YEAR FROM period) = ? AND EXTRACT(MONTH FROM period) = ?", today.year, today.month)
      expect(described_class.for_year_and_month(today.year, today.month).to_sql).to eq(expected_query.to_sql)
    end

    it "has a for_year scope" do
      year = Date.today.year
      expected_query = described_class.where("EXTRACT(YEAR FROM period) = ?", year)
      expect(described_class.for_year(year).to_sql).to eq(expected_query.to_sql)
    end

    it "has a for_fee_due scope" do
      expected_query = described_class.where(fee_due: true)
      expect(described_class.for_fee_due(true).to_sql).to eq(expected_query.to_sql)
    end
  end
end
