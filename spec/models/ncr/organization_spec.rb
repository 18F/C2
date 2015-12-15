describe Ncr::Organization do
  describe "Validations" do
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code) }
    it { should validate_presence_of(:name) }
  end

  describe "#ool?" do
    it "returns true for an Office of Leasing org code" do
      organization = build(:ncr_organization, code: Ncr::Organization::OOL_CODES.first)

      expect(organization).to be_ool
    end

    it "returns false for other org codes" do
      organization = build(:ncr_organization, code: "Blah")

      expect(organization).not_to be_ool
    end
  end

  describe "#whsc?" do
    it "returns true for a White House Service Center org code" do
      organization = build(:ncr_organization, code: Ncr::Organization::WHSC_CODE)

      expect(organization).to be_whsc
    end

    it "returns false for other org codes" do
      organization = build(:ncr_organization, code: "blargh")

      expect(organization).not_to be_whsc
    end
  end
end
