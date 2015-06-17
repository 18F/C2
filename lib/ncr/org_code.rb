module Ncr
  class OrgCode
    ROWS = CSV.read("#{Rails.root}/config/data/ncr/org_codes_2015-05-18.csv", headers: true)
    # TODO reference by `organization_cd` rather than storing the whole thing

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
      ROWS.map{|row| self.new(row) }
    end
  end
end
