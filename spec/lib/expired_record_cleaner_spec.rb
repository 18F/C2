describe ExpiredRecordCleaner do
  describe "fiscal year" do
    it "parses fiscal start date" do
      Timecop.freeze(Time.zone.parse('2015-10-02')) do
        fy = Time.zone.parse('2015-10-01')
        expect(ExpiredRecordCleaner.new(Time.zone.now).fiscal_year_start).to eq(fy)
      end
    end
  end

  describe ".vaccum_old_proposals" do
    it "locates old pending proposals but does not act on them" do
      proposal = create(:proposal)
      Timecop.travel(Time.zone.now + 1.year) do
        cleaner = ExpiredRecordCleaner.new(Time.zone.now)
        expect(cleaner.vacuum_old_proposals).to eq([proposal.id])
        expect(deliveries.length).to eq(0)
        proposal.reload
        expect(proposal.status).to eq("pending")
      end
    end

    it "cancels old pending proposals" do
      proposal = create(:proposal)
      Timecop.travel(Time.zone.now + 1.year) do
        cleaner = ExpiredRecordCleaner.new(Time.zone.now, true)
        expect(cleaner.vacuum_old_proposals).to eq([proposal.id])
        expect(deliveries.length).to eq(1)
        proposal.reload
        expect(proposal.status).to eq("cancelled")
      end 
    end
  end

  describe ".vacuum_proposal" do
    it "cleans up specific proposal" do
      proposal = create(:proposal)
      cleaner = ExpiredRecordCleaner.new(Time.zone.now, true)
      cleaner.vacuum_proposal(proposal)
      expect(deliveries.length).to eq(1)
      proposal.reload
      expect(proposal.status).to eq('cancelled')
    end
  end
end

