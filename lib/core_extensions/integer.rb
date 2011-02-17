class Integer
  def real
    Money.new :amount => (self * 100)
  end
  
  def reais
    real
  end
  
  def reals
    real
  end
end