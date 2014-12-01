module Exporter
  class Base
    attr_reader :cart

    def initialize(cart_model)
      @cart = cart_model
    end

    def to_csv
      CSV.generate do |csv|
        csv << self.headers
        self.rows.each do |row|
          csv << row
        end
      end
    end
  end
end
