require_relative "../../../db/chores/ncr_organization_importer"

describe Ncr::OrganizationImporter do
  describe "#run" do
    it "creates Ncr::Organization records" do
      expect {
        Ncr::OrganizationImporter.new.run
      }.to change { Ncr::Organization.count }
    end

    it "is indempotent" do
      Ncr::OrganizationImporter.new.run

      expect {
        Ncr::OrganizationImporter.new.run
      }.not_to change { Ncr::Organization.count }
    end
  end
end
