describe Query::Proposal::Clauses do
  describe "#for_client_slug" do
    it "returns all proposals for the client slug" do
      _general_proposal = create(:proposal)
      gsa_proposal = create(:gsa18f_procurement).proposal

      query = Query::Proposal::Clauses.new.for_client_slug("gsa_18f")

      expect(Proposal.where(query)).to eq([gsa_proposal])
    end
  end

  describe "#which_involve" do
    it "includes proposals where user is requester" do
      create(:proposal)
      proposal = create(:proposal)

      query = Query::Proposal::Clauses.new.which_involve(proposal.requester)

      expect(Proposal.where(query)).to eq([proposal])
    end

     it "returns proposals where user is approver" do
      create(:proposal, :with_approver)
      proposal = create(:proposal, :with_approver)
      approver = proposal.approvers.first

      query = Query::Proposal::Clauses.new.which_involve(approver)

      expect(Proposal.where(query)).to eq([proposal])
     end

     it "returns proposals where user is observer" do
       observer = create(:user)
       proposal = create(:proposal, observer: observer)

       query = Query::Proposal::Clauses.new.which_involve(observer)

       expect(Proposal.where(query)).to eq([proposal])
     end

     it "returns proposal where user is delegate" do
        delegate1 = create(:user)
        _proposal1 = create(:proposal, delegate: delegate1)

        delegate2 = create(:user)
        proposal2 = create(:proposal, delegate: delegate2)

        query = Query::Proposal::Clauses.new.which_involve(delegate2)

        expect(Proposal.where(query)).to eq([proposal2])
     end
  end
end
