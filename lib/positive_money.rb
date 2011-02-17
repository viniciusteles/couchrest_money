class PositiveMoney < Money
  validates :amount, :positive_money => true
end