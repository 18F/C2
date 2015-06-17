module Ncr
  class OrgCode
    # TODO reference by `code` rather than storing the whole thing

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

    def self.all
      ALL
    end
  end
end

rows = CSV.read("#{Rails.root}/config/data/ncr/org_codes_2015-05-18.csv", headers: true)
Ncr::OrgCode::ALL = rows.map{|row| Ncr::OrgCode.new(row) }
