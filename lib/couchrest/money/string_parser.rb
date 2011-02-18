module CouchRest
  class Money
    class StringParser
      def self.parse(value, doc)
        if integer?(value)
          doc.write_attribute(:amount, value.to_i * 100)
        else
          doc.write_attribute(:amount, (value.gsub(',', '.').to_f * 100).round)
        end
      end

      private

      def self.integer?(value)
        value.strip =~ /^[-]?(\d+)$/
      end
    end
  end
end