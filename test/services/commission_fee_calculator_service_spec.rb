require_relative "../test_helper"

RSpec.describe CommissionFeeCalculatorService do
  describe 'between 0 and 50' do
    it "should return 0 if the amount is 0" do
      ### Given
      amount = 0.0

      ### When
      result = CommissionFeeCalculatorService.calculate(amount)

      ### Then
      expect(result).to eq(0)
    end

    it "should return 0.1 if the amount is 10" do
      ### Given
      amount = 10.0

      ### When
      result = CommissionFeeCalculatorService.calculate(amount)

      ### Then
      expect(result).to eq(0.1)
    end
  end

  describe 'between 50 (included) and 300 (excluded)' do
    it "should return 0.48 if the amount is 50" do
      ### Given
      amount = 50.0

      ### When
      result = CommissionFeeCalculatorService.calculate(amount)

      ### Then
      expect(result).to eq(0.48)
    end

    it "should return 2.84 if the amount is 299" do
      ### Given
      amount = 299.0

      ### When
      result = CommissionFeeCalculatorService.calculate(amount)

      ### Then
      expect(result).to eq(2.84)
    end
  end

  describe 'from 300 onwards' do
    it "should return 2.55 if the amount is 300" do
      ### Given
      amount = 300.0

      ### When
      result = CommissionFeeCalculatorService.calculate(amount)

      ### Then
      expect(result).to eq(2.55)
    end

    it "should return 2.84 if the amount is 299" do
      ### Given
      amount = 299.0

      ### When
      result = CommissionFeeCalculatorService.calculate(amount)

      ### Then
      expect(result).to eq(2.84)
    end
  end

  describe 'below 0' do
    it "should return 0 if the amount is negative" do
      ### Given
      amount = -10.0

      ### When
      result = CommissionFeeCalculatorService.calculate(amount)

      ### Then
      expect(result).to eq(0)
    end
  end
end
