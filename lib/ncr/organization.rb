module Ncr
  class Organization
    BY_CODE = {} # populated later
    OOL_CODES = Set.new # populated later
    WHSC_CODE = "P1122021"

    attr_accessor :code, :name

    def initialize(code:, name:)
      self.code = code
      self.name = name
    end

    def ==(other)
      other.code == code
    end

    def to_s
      "#{code} #{name}"
    end

    # Office of Leasing
    def ool?
      OOL_CODES.include?(code)
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
      rows = CSV.read(Rails.root.join(*%w(config data ncr org_codes_2015-05-18.csv)), headers: true)
      rows.each do |row|
        org = self.from_csv_row(row)
        BY_CODE[org.code] = org
      end
    end

    def self.load_ool_yaml
      data = YAML.load_file(Rails.root.join(*%w(config data ncr ool_org_codes.yml)))
      data.each do |code, project_title|
        org = self.new(code: code, name: name)
        BY_CODE[code] = org
        OOL_CODES << code
      end
    end

    self.load_csv
    self.load_ool_yaml
  end
end
