describe Ncr::Building do
  describe '.all' do
    it "returns all records" do
      expect(Ncr::Building.all.size).to be > 10
    end

    it "populates the name for each" do
      Ncr::Building.all.each do |building|
        expect(building.name).to be_present
      end
    end
  end
end
