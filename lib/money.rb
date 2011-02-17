class Money < Hash
  include CouchRest::Model::CastedModel
  
  property :amount, Integer
  
  validates :amount, :presence => true, :money => true
  
  def amount=(value)
    if value.kind_of?(Money)
      @amount = value['amount'] || value[:amount]
    else
      @amount = value
    end
    store_amount(@amount)
  end
  
  def store_amount(value)
    case
    when value.kind_of?(Float)
      FloatParser.parse(value, self)
    when value.kind_of?(BigDecimal)
      BigDecimalParser.parse(value, self)
    when value.kind_of?(String) && value.numeric?
      StringParser.parse(value, self)
    when value.kind_of?(Integer)
      IntegerParser.parse(value, self)
    end
  end
  
  def self.from_string(value)
    return Money.new(:amount => (value.strip.gsub(",", ".").to_f * 100).round) if value.numeric?
  end
  
  def self.from_float(value)
    Money.new :amount => (value * 100).round
  end
  
  def self.from_cents(value)
    return Money.new(:amount => value.to_i) if value.numeric?
  end
  
  def amount
    @amount || read_attribute(:amount)
  end
  
  def ==(other)
    self['amount'] == other['amount']
  end
  
  def to_f
    read_attribute(:amount) / 100.0
  end
  
  def to_s
    format("%.2f", to_f)
  end
  
  def to_str
    to_s
  end
end