class String
  def numeric?
    result = self.strip =~ /^[-]?(\d+)$/ ||
             self.strip =~ /^([-]?\d*)[,.](\d+)$/ || 
             self.strip =~ /^([-]?\d+)[,.](\d*)$/
    !!result
  end
  
  def real
    CouchRest::Money.from_string(self)
  end
  
  def reais
    real
  end
  
  def reals
    real
  end
  
  def centavo
    CouchRest::Money.from_cents(self)
  end
  
  def centavos
    centavo
  end
  
  def cents
    centavo
  end
  
  def cent
    centavo
  end
end