describe Vacuum do
  describe "fiscal year" do
    it "parses fiscal start date" do
      Timecop.freeze(Time.zone.parse('2015-10-02')) do
        fy = Time.zone.parse('2015-10-01')
        expect(Vacuum.new(Time.zone.now).fiscal_year_start).to eq(fy)
      end
    end
  end

  describe ".old_proposals" do
    it "locates old pending proposals" do
      proposal = create(:proposal)
      Timecop.travel(Time.zone.now + 1.year) do
        vacuum = Vacuum.new(Time.zone.now, true)
        expect(vacuum.old_proposals).to eq([proposal.id])
        expect(deliveries.length).to eq(1)
      end
    end
  end

  describe ".proposal" do
    it "cleans up specific proposal" do
      proposal = create(:proposal)
      vacuum = Vacuum.new(Time.zone.now, true)
      vacuum.proposal(proposal)
      expect(deliveries.length).to eq(1)
      proposal.reload
      expect(proposal.status).to eq('cancelled')
    end
  end
end

