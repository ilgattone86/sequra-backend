require_relative '../test_helper'

RSpec.describe Order, type: :model do

  it 'has associations' do
    should belong_to(:merchant).class_name('::Merchant')
    should belong_to(:disbursement).class_name('::Disbursement').optional
  end

  describe 'scopes' do
    it 'has a for_merchant scope' do
      expected_query = described_class.where(merchant: 1)
      expect(described_class.for_merchant(1).to_sql).to eq(expected_query.to_sql)
    end

    it 'has a disbursed scope' do
      expected_query = described_class.where.not(disbursement: nil)
      expect(described_class.disbursed.to_sql).to eq(expected_query.to_sql)
    end

    it 'has a not_disbursed scope' do
      expected_query = described_class.where(disbursement: nil)
      expect(described_class.not_disbursed.to_sql).to eq(expected_query.to_sql)
    end

    it 'has a for_order_received_at scope' do
      today = Date.today
      expected_query = described_class.where(order_received_at: today)
      expect(described_class.for_order_received_at(today).to_sql).to eq(expected_query.to_sql)
    end

    it 'has a for_order_received_in_range scope' do
      range = Date.today..Date.tomorrow
      expected_query = described_class.where(order_received_at: range)
      expect(described_class.for_order_received_in_range(range).to_sql).to eq(expected_query.to_sql)
    end

    it 'has a for_order_received_between scope' do
      from = Date.today
      to = Date.tomorrow
      expected_query = described_class.where(order_received_at: from..to)
      expect(described_class.for_order_received_between(from, to).to_sql).to eq(expected_query.to_sql)
    end
  end

  describe 'methods' do
    it 'should call the commission fee calculator service' do
      amount = 100.0
      order = Order.new(amount: amount)
      expect(CommissionFeeCalculatorService).to receive(:calculate).with(amount)
      order.commission_fee
    end
  end
end
