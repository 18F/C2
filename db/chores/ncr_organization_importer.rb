module Ncr
  class OrganizationImporter
    def run
      rows.each do |row|
        Ncr::Organization.find_or_create_by(
          code: row["organization_cd"],
          name: row["organization_nm"]
        )
      end
    end

    private

    def rows
      @_rows ||= CSV.read(Rails.root.join(*%w(config data ncr org_codes_2015-05-18.csv)), headers: true)
    end
  end
end
