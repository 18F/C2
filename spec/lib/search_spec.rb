describe Search do
  describe '.find_proposals' do
    it "returns an empty list for no Proposals" do
      results = Search.find_proposals('')
      expect(results).to eq([])
    end

    # it "returns all Proposals for an empty search" do
    #   proposal = FactoryGirl.create(:proposal)
    #   results = Search.find_proposals('')
    #   expect(results).to eq([proposal])
    # end

    it "returns the Proposal when searching by ID" do
      proposal = FactoryGirl.create(:proposal)
      results = Search.find_proposals(proposal.id.to_s)
      expect(results).to eq([proposal])
    end
  end
end
