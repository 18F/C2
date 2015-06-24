module Ncr
  class Building
    # each is guaranteed to have a `name` property present, but not necessarily a `number`
    attr_accessor :name, :number

    def initialize(attrs)
      self.name = attrs['name']
      self.number = attrs['number']
    end

    def id
      self.number || self.name
    end

    def to_s
      if self.number
        "#{self.number} - #{self.name}"
      else
        self.name
      end
    end

    def self.all
      ALL.dup
    end

    def self.first
      ALL.first
    end
  end
end

data = YAML.load_file(Rails.root.join('config', 'data', 'ncr', 'building_numbers.yml'))
Ncr::Building::ALL = data.map{|d| Ncr::Building.new(d) }
