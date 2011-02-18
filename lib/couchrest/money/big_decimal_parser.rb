module CouchRest
  class Money
    class BigDecimalParser
      def self.parse(value, doc)
        FloatParser.parse(value.to_f, doc)
      end
    end
  end
end