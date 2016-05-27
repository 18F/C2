module Ncr
  class OrganizationImporter
    def run(filename: nil)
      rows(filename).each do |row|
        Ncr::Organization.find_or_create_by(
          code: row["organization_cd"],
          name: row["organization_nm"]
        )
      end
    end

    private

    def rows(filename)
      if filename.nil?
        filename = Rails.root.join(*%w(config data ncr org_codes_2015-05-18.csv))
      end
      @_rows ||= CSV.read(filename, headers: true)
    end
  end
end
