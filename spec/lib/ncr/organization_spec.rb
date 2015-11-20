describe Ncr::Organization do
  describe "#to_s" do
    it "returns code and name" do
      org = Ncr::Organization.new(code: "123", name: "ABC")

      expect(org.to_s).to eq "123 ABC"
    end
  end
  describe "#ool?" do
    it "returns true for an Office of Leasing org code" do
      ool_org = Ncr::Organization.new(code: Ncr::Organization::OOL_CODES[0], name: "test")
      expect(ool_org.ool?).to eq(true)
    end

    it "returns false for other org codes" do
      org = Ncr::Organization.new(code: "12", name: "foo")
      expect(org.ool?).to eq(false)
    end
  end

  describe "#whsc?" do
    it "returns true for a White House Service Center org code" do
      org = Ncr::Organization.new(code: Ncr::Organization::WHSC_CODE, name: "test")
      expect(org.whsc?).to eq(true)
    end

    it "returns false for other org codes" do
      org = Ncr::Organization.new(code: "12", name: "foo")
      expect(org.whsc?).to eq(false)
    end
  end

  describe ".find" do
    it "returns Ncr Organization based on code" do
      code = Ncr::Organization::WHSC_CODE
      name_from_fixture = "(192X,192M) WHITE HOUSE DISTRICT"
      org = Ncr::Organization.new(code: code, name: name_from_fixture)

      expect(Ncr::Organization.find(code).code).to eq org.code
      expect(Ncr::Organization.find(code).name).to eq org.name
    end
  end
end
