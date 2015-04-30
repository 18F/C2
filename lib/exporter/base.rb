module Exporter
  class Base
    attr_reader :proposal

    def initialize(proposal_model)
      @proposal = proposal_model
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
