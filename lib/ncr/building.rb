module Ncr
  class Building
    # each is guaranteed to have a `name` property present, but not necessarily a `number`
    attr_reader :name, :number, :original

    def initialize(row)
      @original = row

      match = row.match(/^(.{8}) (-|,)\s*(\w.*)$/)
      if match
        @number = match[1]
        @name = match[3]
      else
        # no number
        @name = row
      end
    end

    def to_s
      self.original
    end

    def self.all
      ALL.dup
    end
  end
end

rows = YAML.load_file("#{Dir.pwd}/config/data/ncr/building_numbers.yml")
Ncr::Building::ALL = rows.map{|row| Ncr::Building.new(row) }
