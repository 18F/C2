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

  describe '.proposals_tier_one_pending' do
    it "only returns Proposals where Tier One approval is actionable" do
      approver_email = 'i-approve@example.gov'

      whs_work_order = FactoryGirl.create(:ncr_work_order, :with_approvers)
      whs_work_order.update_attribute(:org_code, Ncr::Organization::WHSC_CODE)
      whs_work_order.setup_approvals_and_observers(approver_email)

      approved_work_order = FactoryGirl.create(:ncr_work_order, :with_approvers)
      approved_work_order.setup_approvals_and_observers(approver_email)
      approved_work_order.individual_approvals.first.approve!

      alt_work_order = FactoryGirl.create(:ncr_work_order, :with_approvers)
      alt_work_order.setup_approvals_and_observers(approver_email)

      expect(Ncr::Reporter.proposals_tier_one_pending).to eq([approved_work_order.proposal])
    end
  end
end
