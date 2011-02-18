module CouchRest
  class Money
    class IntegerParser
      def self.parse(value, doc)
        doc.write_attribute(:amount, value)
      end
    end
  end
end