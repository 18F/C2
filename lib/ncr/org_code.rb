module Ncr
  class OrgCode
    org_code_rows = CSV.read("#{Rails.root}/config/data/ncr/org_codes_2015-05-18.csv", headers: true)
    # TODO reference by `organization_cd` rather than storing the whole thing
    ALL = org_code_rows.map{|r| "#{r['organization_cd']} #{r['organization_nm']}" }

    def self.all
      ALL
    end
  end
end
