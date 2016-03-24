describe Gsa18f::ProcurementFields do
  describe '#relevant' do
    it "returns recurring fields if recurring is true" do
      fields = Gsa18f::ProcurementFields.new.relevant(true)

      expect(fields).to include(:recurring_interval)
      expect(fields).to include(:recurring_length)
    end

    it "does not return recurring fields if recurring is false" do
      fields = Gsa18f::ProcurementFields.new.relevant(false)

      expect(fields).not_to include(:recurring_interval)
      expect(fields).not_to include(:recurring_length)
    end
  end
end
