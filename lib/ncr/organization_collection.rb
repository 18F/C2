module Ncr
  class OrganizationCollection
    def all
      organization_records
    end

    def finder
      Hash[organization_codes.zip(organization_records)]
    end

    private

    attr_reader :type

    def organization_codes
      org_code_data.map do |row|
        row["organization_cd"]
      end
    end

    def organization_records
      org_code_data.map do |row|
        Ncr::Organization.new(
          code: row["organization_cd"],
          name: row["organization_nm"]
        )
      end
    end

    def org_code_data
      @org_code_data ||= CSV.read(
        Rails.root.join(*%w(config data ncr org_codes_2015-05-18.csv)),
        headers: true
      )
    end
  end
end
