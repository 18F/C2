require File.join(Rails.root, "/db/chores/ncr_organization_importer")

SAMPLE_NCR_ORG_CODES = "spec/support/fixtures/sample_ncr_org_codes.csv".freeze

describe Ncr::OrganizationImporter do
  describe "#run" do
    it "creates Ncr::Organization records" do
      expect do
        Ncr::OrganizationImporter.new.run(filename: SAMPLE_NCR_ORG_CODES)
      end.to change { Ncr::Organization.count }
    end

    it "is indempotent" do
      Ncr::OrganizationImporter.new.run(filename: SAMPLE_NCR_ORG_CODES)

      expect do
        Ncr::OrganizationImporter.new.run(filename: SAMPLE_NCR_ORG_CODES)
      end.not_to change { Ncr::Organization.count }
    end
  end
end
