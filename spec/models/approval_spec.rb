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

  describe '#approved_at' do
    it 'is nil when pending' do
      expect(approval.approved_at).to be_nil
    end

    it 'is nil when actionable' do
      approval.initialize!
      expect(approval.approved_at).to be_nil
    end

    it 'is set when approved' do
      approval.initialize!
      approval.approve!
      expect(approval.approved_at).not_to be_nil
      approval.reload
      expect(approval.approved_at).not_to be_nil
    end
  end

  describe '#on_approved_entry' do
    it "notified the proposal if the root gets approved" do
      expect(approval.proposal).to receive(:partial_approve!).once
      approval.initialize!
      approval.approve!
    end

    it "does not notify the proposal if a child gets approved" do
      proposal = FactoryGirl.create(:proposal)
      root = Approvals::Parallel.new
      child1 = Approvals::Individual.new(user: User.for_email("child1@agency.gov"), parent: root)
      child2 = Approvals::Individual.new(user: User.for_email("child2@agency.gov"), parent: root)
      proposal.approvals = [root, child1, child2]

      expect(proposal).not_to receive(:partial_approve!)
      root.initialize!
      child1.reload.approve!
    end
  end

  describe "complicated approval chains" do
    # Approval hierarchy version of needing *two* of the following:
    # 1) Amy AND Bob
    # 2) Carrie
    # 3) Dan THEN Erin
    let!(:amy) { FactoryGirl.create(:user) }
    let!(:bob) { FactoryGirl.create(:user) }
    let!(:carrie) { FactoryGirl.create(:user) }
    let!(:dan) { FactoryGirl.create(:user) }
    let!(:erin) { FactoryGirl.create(:user) }
    let!(:proposal) { FactoryGirl.create(:proposal) }

    before :each do
      # @todo syntax for this will get cleaned up
      and_clause = Approvals::Parallel.new
      and_clause.child_approvals = [Approvals::Individual.new(user: amy),
                                    Approvals::Individual.new(user: bob)]
      then_clause = Approvals::Serial.new
      then_clause.child_approvals = [Approvals::Individual.new(user: dan),
                                     Approvals::Individual.new(user: erin)]

      root = Approvals::Parallel.new(min_children_needed: 2)
      root.child_approvals = [and_clause,
                              Approvals::Individual.new(user: carrie),
                              then_clause]

      proposal.approvals = [root] + root.child_approvals + and_clause.child_approvals + then_clause.child_approvals
      root.initialize!
    end

    it "won't approve Amy and Bob -- needs two branches of the OR" do
      expect_any_instance_of(Proposal).not_to receive(:partial_approve!)
      proposal.existing_approval_for(amy).approve!
      proposal.existing_approval_for(bob).approve!
    end

    it "will approve if Amy, Bob, and Carrie approve -- two branches of the OR" do
      expect_any_instance_of(Proposal).to receive(:partial_approve!)
      proposal.existing_approval_for(amy).approve!
      proposal.existing_approval_for(bob).approve!
      proposal.existing_approval_for(carrie).approve!
    end

    it "won't approve Amy, Bob, Dan as Erin is also required (to complete the THEN)" do
      expect_any_instance_of(Proposal).not_to receive(:partial_approve!)
      proposal.existing_approval_for(amy).approve!
      proposal.existing_approval_for(bob).approve!
      proposal.existing_approval_for(dan).approve!
    end

    it "will approve Amy, Bob, Dan, Erin -- two branches of the OR" do
      expect_any_instance_of(Proposal).to receive(:partial_approve!)
      proposal.existing_approval_for(amy).approve!
      proposal.existing_approval_for(bob).approve!
      proposal.existing_approval_for(dan).approve!
      proposal.existing_approval_for(erin).approve!
    end

    it "will approve Amy, Bob, Dan, Carrie -- two branches of the OR as Dan is irrelevant" do
      expect_any_instance_of(Proposal).to receive(:partial_approve!)
      proposal.existing_approval_for(amy).approve!
      proposal.existing_approval_for(bob).approve!
      proposal.existing_approval_for(dan).approve!
      proposal.existing_approval_for(carrie).approve!
    end
  end
end
