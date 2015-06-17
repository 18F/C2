module Ncr
  class Organization
    WHSC_CODE = 'P1122021'

    attr_accessor :code, :name

    def initialize(row)
      self.code = row['organization_cd']
      self.name = row['organization_nm']
    end

    def ==(other)
      other.code == self.code
    end

    def to_s
      "#{self.code} #{self.name}"
    end

    # White House Service Center
    def whsc?
      self.code == WHSC_CODE
    end

    def self.all
      BY_CODE.values
    end

    def self.find(code)
      BY_CODE[code]
    end
  end
end

rows = CSV.read("#{Rails.root}/config/data/ncr/org_codes_2015-05-18.csv", headers: true)

Ncr::Organization::BY_CODE = {}
rows.each do |row|
  org = Ncr::Organization.new(row)
  Ncr::Organization::BY_CODE[org.code] = org
end
