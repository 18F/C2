module Ncr
  class Organization
    BY_CODE = {} # populated later
    WHSC_CODE = 'P1122021'

    attr_accessor :code, :name

    def initialize(code:, name:)
      self.code = code
      self.name = name
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

    def self.from_csv_row(row)
      self.new(
        code: row['organization_cd'],
        name: row['organization_nm']
      )
    end

    protected

    def self.load_csv
      rows = CSV.read("#{Rails.root}/config/data/ncr/org_codes_2015-05-18.csv", headers: true)
      rows.each do |row|
        org = Ncr::Organization.from_csv_row(row)
        Ncr::Organization::BY_CODE[org.code] = org
      end
    end

    def self.load_yaml
      data = YAML.load_file(Rails.root.join(*%w(config data ncr ool_org_codes.yml)))
      data.each do |code, name|
        org = Ncr::Organization.new(code: code, name: name)
        Ncr::Organization::BY_CODE[code] = org
      end
    end

    self.load_csv
    self.load_yaml
  end
end
