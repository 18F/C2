describe Ncr::Reporter do
  describe '.proposals_pending_approving_official' do
    it "only returns Proposals where the approving official is actionable" do
      partially_approved = FactoryGirl.create(:ncr_work_order, :with_approvers)
      partially_approved.individual_approvals.first.approve!

      actionable = FactoryGirl.create(:ncr_work_order, :with_approvers)

      expect(Ncr::Reporter.proposals_pending_approving_official).to eq([actionable.proposal])
    end
  end

  describe '.proposals_pending_budget' do
    it "only returns Proposals where the budget approver is actionable" do
      FactoryGirl.create(:ncr_work_order, :with_approvers)

      actionable = FactoryGirl.create(:ncr_work_order, :with_approvers)
      # all but the last
      actionable.individual_approvals[0...-1].each(&:approve!)

      expect(Ncr::Reporter.proposals_pending_budget).to eq([actionable.proposal])
    end
  end
end
