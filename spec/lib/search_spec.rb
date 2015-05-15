describe Search do
  describe '#execute' do
    it "returns an empty list for no Proposals" do
      results = Search.new.execute('')
      expect(results).to eq([])
    end

    it "returns the Proposal when searching by ID" do
      proposal = FactoryGirl.create(:proposal)
      results = Search.new.execute(proposal.id.to_s)
      expect(results).to eq([proposal])
    end

    it "can operate on an a relation" do
      proposal = FactoryGirl.create(:proposal)
      relation = Proposal.where(id: proposal.id + 1)
      results = Search.new(relation).execute(proposal.id.to_s)
      expect(results).to eq([])
    end

    it "returns an empty list for no matches" do
      FactoryGirl.create(:proposal)
      results = Search.new.execute('asgsfgsfdbsd')
      expect(results).to eq([])
    end

    it "returns the Proposal when searching by the WorkOrder#project_title" do
      work_order = FactoryGirl.create(:ncr_work_order, :with_proposal)
      results = Search.new.execute(work_order.project_title)
      expect(results).to eq([work_order.proposal])
    end
  end
end
