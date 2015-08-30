describe Query::Proposal::Clauses do
  describe '.with_requester' do
    it "returns matches" do
      FactoryGirl.create(:proposal)
      proposal = FactoryGirl.create(:proposal)

      condition = Query::Proposal::Clauses.with_requester(proposal.requester)
      expect(Proposal.where(condition)).to eq([proposal])
    end
  end

  describe '.with_approver_or_delegate' do
    it "returns approver matches" do
      FactoryGirl.create(:proposal, :with_approver)
      proposal = FactoryGirl.create(:proposal, :with_approver)
      approver = proposal.approvers.first

      condition = Query::Proposal::Clauses.with_approver_or_delegate(approver)
      expect(Proposal.where(condition)).to eq([proposal])
    end

    it "returns delegate matches" do
      proposal1 = FactoryGirl.create(:proposal, :with_approver)
      approver1 = proposal1.approvers.first
      delegate1 = FactoryGirl.create(:user)
      approver1.add_delegate(delegate1)

      proposal2 = FactoryGirl.create(:proposal, :with_approver)
      approver2 = proposal2.approvers.first
      delegate2 = FactoryGirl.create(:user)
      approver2.add_delegate(delegate2)

      condition = Query::Proposal::Clauses.with_approver_or_delegate(delegate2)
      expect(Proposal.where(condition)).to eq([proposal2])
    end
  end

  describe '.with_observer' do
    it "returns matches" do
      FactoryGirl.create(:proposal, :with_observer)

      proposal = FactoryGirl.create(:proposal, :with_observer)
      observer = proposal.observers.first

      condition = Query::Proposal::Clauses.with_observer(observer)
      expect(Proposal.where(condition)).to eq([proposal])
    end
  end
end
