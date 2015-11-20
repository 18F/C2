describe Ncr::OrganizationCollection do
  describe "#all" do
    it "returns a collection of all Ncr Organization records" do
      collection = Ncr::OrganizationCollection.new.all

      expect(collection.size).to eq 891
      expect(collection.first).to be_an_instance_of(Ncr::Organization)
    end
  end

  describe "#finder" do
    it "returns a hash with org codes pointing to objects for code" do
      code = Ncr::Organization::WHSC_CODE
      name_from_fixture = "(192X,192M) WHITE HOUSE DISTRICT"
      org = Ncr::Organization.new(code: code, name: name_from_fixture)

      found_org = Ncr::OrganizationCollection.new.finder[code]

      expect(found_org.code).to eq org.code
      expect(found_org.name).to eq org.name
    end
  end
end
