describe Ncr::Organization do
  describe '#==' do
    it "considers two objects with the same #code identical" do
      expect(Ncr::Organization.new(code: '12', project_title: 'foo')).to eq(
        Ncr::Organization.new(code: '12', project_title: 'foo')
      )
    end
  end

  describe '#ool?' do
    it "returns true for an Office of Leasing org code" do
      org = Ncr::Organization.find(Ncr::Organization::OOL_CODES.first)
      expect(org.ool?).to eq(true)
    end

    it "returns false for other org codes" do
      org = Ncr::Organization.new(code: '12', project_title: 'foo')
      expect(org.ool?).to eq(false)
    end
  end

  describe '#whsc?' do
    it "returns true for a White House Service Center org code" do
      org = Ncr::Organization.find(Ncr::Organization::WHSC_CODE)
      expect(org.whsc?).to eq(true)
    end

    it "returns false for other org codes" do
      org = Ncr::Organization.new(code: '12', project_title: 'foo')
      expect(org.whsc?).to eq(false)
    end
  end

  describe '.all' do
    it "returns all records" do
      expect(Ncr::Organization.all.size).to be > 10
    end

    it "populates the attributes for each" do
      Ncr::Organization.all.each do |org|
        expect(org.code).to be_present
        expect(org.project_title).to be_present
      end
    end
  end
end
