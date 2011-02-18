class Integer
  def real
    CouchRest::Money.new :amount => (self * 100)
  end
  
  def reais
    real
  end
  
  def reals
    real
  end
end