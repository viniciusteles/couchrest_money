class Money
  class FloatParser 
    def self.parse(value, doc)
      doc.write_attribute(:amount, (value * 100).round)
    end
  end
end