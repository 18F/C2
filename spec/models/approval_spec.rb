describe Approval do
  let(:approval) { FactoryGirl.create(:approval) }

  describe '#api_token' do
    let!(:token) { approval.create_api_token! }

    it "returns the token" do
      expect(approval.api_token).to eq(token)
    end

    it "returns nil if the token's been used" do
      token.update_attribute(:used_at, 1.day.ago)
      approval.reload
      expect(approval.api_token).to eq(nil)
    end

    it "returns nil if the token's expired" do
      token.update_attribute(:expires_at, 1.day.ago)
      approval.reload
      expect(approval.api_token).to eq(nil)
    end
  end

  describe '#on_approved_entry' do
    it "notified the proposal if the root gets approved" do
      expect(approval.proposal.approved?).to eq false
      approval.make_actionable!
      approval.approve!
      expect(approval.proposal.approved?).to eq true
    end

    it "does not notify the proposal if a child gets approved" do
      proposal = FactoryGirl.create(:proposal)
      proposal.root_approval = Approvals::Parallel.new
      child1 = proposal.add_approver("child1@agency.gov")
      proposal.add_approver("child2@agency.gov")
      proposal.root_approval.make_actionable!

      expect(approval.proposal.approved?).to eq false
      child1.reload.approve!
      expect(approval.proposal.approved?).to eq false
      expect(approval.proposal.pending?).to eq true
    end
  end

  describe "complicated approval chains" do
    # Approval hierarchy version of needing two of the following:
    # 1) Amy AND Bob
    # 2) Carrie
    # 3) Dan THEN Erin
    let!(:amy) { FactoryGirl.create(:user) }
    let!(:bob) { FactoryGirl.create(:user) }
    let!(:carrie) { FactoryGirl.create(:user) }
    let!(:dan) { FactoryGirl.create(:user) }
    let!(:erin) { FactoryGirl.create(:user) }
    let!(:proposal) {
      proposal = FactoryGirl.create(:proposal)
      proposal.root_approval = Approvals::Parallel.create(min_required: 2)
      and_clause = Approvals::Parallel.create(parent: proposal.root_approval, proposal: proposal)
      then_clause = Approvals::Serial.create(parent: proposal.root_approval, proposal: proposal)

      FactoryGirl.create(:approval, user: amy, proposal: proposal, parent: and_clause)
      FactoryGirl.create(:approval, user: bob, proposal: proposal, parent: and_clause)
      FactoryGirl.create(:approval, user: carrie, proposal: proposal, parent: proposal.root_approval)
      FactoryGirl.create(:approval, user: dan, proposal: proposal, parent: then_clause)
      FactoryGirl.create(:approval, user: erin, proposal: proposal, parent: then_clause)
      proposal.root_approval.make_actionable!
      proposal
    }

    it "approves via Amy, Bob, Carrie" do
      expect(proposal.reload.approved?).to be false
      proposal.approval_for(amy).approve!
      expect(proposal.reload.approved?).to be false
      proposal.approval_for(bob).approve!
      expect(proposal.reload.approved?).to be false
      proposal.approval_for(carrie).approve!
      expect(proposal.reload.approved?).to be true
    end

    it "approved via Amy, Bob, Dan, Erin" do
      expect(proposal.reload.approved?).to be false
      proposal.approval_for(amy).approve!
      expect(proposal.reload.approved?).to be false
      proposal.approval_for(bob).approve!
      expect(proposal.reload.approved?).to be false
      proposal.approval_for(dan).approve!
      expect(proposal.reload.approved?).to be false
      proposal.approval_for(erin).approve!
      expect(proposal.reload.approved?).to be true
    end

    it "approves via Amy, Bob, Dan, Carrie" do
      expect(proposal.reload.approved?).to be false
      proposal.approval_for(amy).approve!
      expect(proposal.reload.approved?).to be false
      proposal.approval_for(bob).approve!
      expect(proposal.reload.approved?).to be false
      proposal.approval_for(dan).approve!
      expect(proposal.reload.approved?).to be false
      proposal.approval_for(carrie).approve!
      expect(proposal.reload.approved?).to be true
    end
  end
end
