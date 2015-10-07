describe Query::Proposal::Clauses do
  describe '.with_requester' do
    it "returns matches" do
      create(:proposal)
      proposal = create(:proposal)

      condition = Query::Proposal::Clauses.with_requester(proposal.requester)
      expect(Proposal.where(condition)).to eq([proposal])
    end
  end

  describe '.with_approver_or_delegate' do
    it "returns approver matches" do
      create(:proposal, :with_approver)
      proposal = create(:proposal, :with_approver)
      approver = proposal.approvers.first

      condition = Query::Proposal::Clauses.with_approver_or_delegate(approver)
      expect(Proposal.where(condition)).to eq([proposal])
    end

    it "returns delegate matches" do
      proposal1 = create(:proposal, :with_approver)
      approver1 = proposal1.approvers.first
      delegate1 = create(:user)
      approver1.add_delegate(delegate1)

      proposal2 = create(:proposal, :with_approver)
      approver2 = proposal2.approvers.first
      delegate2 = create(:user)
      approver2.add_delegate(delegate2)

      condition = Query::Proposal::Clauses.with_approver_or_delegate(delegate2)
      expect(Proposal.where(condition)).to eq([proposal2])
    end
  end

  describe '.with_observer' do
    it "returns matches" do
      create(:proposal, :with_observer)

      proposal = create(:proposal, :with_observer)
      observer = proposal.observers.first

      condition = Query::Proposal::Clauses.with_observer(observer)
      expect(Proposal.where(condition)).to eq([proposal])
    end
  end
end
