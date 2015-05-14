describe Search do
  describe '.find_proposals' do
    it "returns an empty list for no Proposals" do
      results = Search.find_proposals('')
      expect(results).to eq([])
    end

    it "returns the Proposal when searching by ID" do
      proposal = FactoryGirl.create(:proposal)
      results = Search.find_proposals(proposal.id.to_s)
      expect(results).to eq([proposal])
    end

    it "returns an empty list for no matches" do
      FactoryGirl.create(:proposal)
      results = Search.find_proposals('asgsfgsfdbsd')
      expect(results).to eq([])
    end

    it "returns the Proposal when searching by the WorkOrder#project_title" do
      work_order = FactoryGirl.create(:ncr_work_order, :with_proposal)
      results = Search.find_proposals(work_order.project_title)
      expect(results).to eq([work_order.proposal])
    end
  end
end
