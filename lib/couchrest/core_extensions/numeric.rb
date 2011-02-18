class Numeric
  def numeric?
    true
  end
  
  def centavo
    CouchRest::Money.from_cents self
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