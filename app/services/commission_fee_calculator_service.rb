class CommissionFeeCalculatorService
  def self.calculate(amount)
    case amount
    when ...0 then 0
    when 0...50 then (amount * 0.01).round(2)
    when 50...300 then (amount * 0.0095).round(2)
    else (amount * 0.0085).round(2)
    end
  end
end
