describe Step do
  let(:approval) { create(:approval) }

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
      expect(approval.proposal).to receive(:approve!).once
      approval.initialize!
      approval.approve!
    end

    it "does not notify the proposal if a child gets approved" do
      proposal = create(:proposal)
      child1 = Steps::Individual.new(user: create(:user))
      child2 = Steps::Individual.new(user: create(:user))
      proposal.root_step = Steps::Parallel.new(child_approvals: [child1, child2])

      expect(proposal).not_to receive(:approve!)
      child1.approve!
    end
  end

  describe "complicated approval chains" do
    # Approval hierarchy version of needing *two* of the following:
    # 1) Amy AND Bob
    # 2) Carrie
    # 3) Dan THEN Erin
    let!(:amy) { create(:user) }
    let!(:bob) { create(:user) }
    let!(:carrie) { create(:user) }
    let!(:dan) { create(:user) }
    let!(:erin) { create(:user) }
    let!(:proposal) { create(:proposal) }

    before :each do
      # @todo syntax for this will get cleaned up
      and_clause = Steps::Parallel.new(child_approvals: [
        Steps::Individual.new(user: amy),
        Steps::Individual.new(user: bob)
      ])
      then_clause = Steps::Serial.new(child_approvals: [
        Steps::Individual.new(user: dan),
        Steps::Individual.new(user: erin)
      ])
      proposal.root_step = Steps::Parallel.new(min_children_needed: 2, child_approvals: [
        and_clause, 
        Steps::Individual.new(user: carrie),
        then_clause
      ])
    end

    it "won't approve Amy and Bob -- needs two branches of the OR" do
      expect_any_instance_of(Proposal).not_to receive(:approve!)
      proposal.existing_approval_for(amy).approve!
      proposal.existing_approval_for(bob).approve!
    end

    it "will approve if Amy, Bob, and Carrie approve -- two branches of the OR" do
      expect_any_instance_of(Proposal).to receive(:approve!)
      proposal.existing_approval_for(amy).approve!
      proposal.existing_approval_for(bob).approve!
      proposal.existing_approval_for(carrie).approve!
    end

    it "won't approve Amy, Bob, Dan as Erin is also required (to complete the THEN)" do
      expect_any_instance_of(Proposal).not_to receive(:approve!)
      proposal.existing_approval_for(amy).approve!
      proposal.existing_approval_for(bob).approve!
      proposal.existing_approval_for(dan).approve!
    end

    it "will approve Amy, Bob, Dan, Erin -- two branches of the OR" do
      expect_any_instance_of(Proposal).to receive(:approve!)
      proposal.existing_approval_for(amy).approve!
      proposal.existing_approval_for(bob).approve!
      proposal.existing_approval_for(dan).approve!
      proposal.existing_approval_for(erin).approve!
    end

    it "will approve Amy, Bob, Dan, Carrie -- two branches of the OR as Dan is irrelevant" do
      expect_any_instance_of(Proposal).to receive(:approve!)
      proposal.existing_approval_for(amy).approve!
      proposal.existing_approval_for(bob).approve!
      proposal.existing_approval_for(dan).approve!
      proposal.existing_approval_for(carrie).approve!
    end
  end
end
