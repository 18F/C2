describe Ncr::Organization do
  describe '#==' do
    it "considers two objects with the same #code identical" do
      expect(Ncr::Organization.new('organization_cd' => '12')).to eq(Ncr::Organization.new('organization_cd' => '12'))
    end
  end

  describe '.all' do
    it "returns all records" do
      expect(Ncr::Organization.all.size).to be > 10
    end

    it "populates the attributes for each" do
      Ncr::Organization.all.each do |org_code|
        expect(org_code.code).to be_present
        expect(org_code.name).to be_present
      end
    end
  end
end
