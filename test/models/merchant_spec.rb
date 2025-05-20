require_relative "../test_helper"

RSpec.describe Merchant, type: :model do

  it "has associations" do
    should have_many(:orders).class_name("::Order").dependent(:destroy)
    should have_many(:disbursements).class_name("::Disbursement").dependent(:destroy)
  end

  describe "scopes" do
    it "has a live_before scope" do
      today = Date.today
      expected_query = described_class.where(live_on: ..today)
      expect(described_class.live_before(today).to_sql).to eq(expected_query.to_sql)
    end

    it "has a for_live_on_week_day scope" do
      today = Date.today
      expected_query = described_class.where("EXTRACT(DOW FROM live_on) = ?", today.wday)
      expect(described_class.for_live_on_week_day(today).to_sql).to eq(expected_query.to_sql)
    end
  end
end
