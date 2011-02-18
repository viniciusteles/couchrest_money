class Float
  def real
    Money.from_float self
  end
  
  def reais
    real
  end
  
  def reals
    real
  end
end