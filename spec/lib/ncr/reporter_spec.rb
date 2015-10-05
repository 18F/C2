describe Ncr::Reporter do
  describe '.proposals_pending_approving_official' do
    it "only returns Proposals where the approving official is actionable" do
      partially_approved = create(:ncr_work_order, :with_approvers)
      partially_approved.individual_approvals.first.approve!

      actionable = create(:ncr_work_order, :with_approvers)

      expect(Ncr::Reporter.proposals_pending_approving_official).to eq([actionable.proposal])
    end
  end

  describe '.proposals_pending_budget' do
    it "only returns Proposals where the budget approver is actionable" do
      create(:ncr_work_order, :with_approvers)

      actionable = create(:ncr_work_order, :with_approvers)
      # all but the last
      actionable.individual_approvals[0...-1].each(&:approve!)

      expect(Ncr::Reporter.proposals_pending_budget).to eq([actionable.proposal])
    end
  end

  describe '.proposals_tier_one_pending' do
    it "only returns Proposals where Tier One approval is actionable" do
      whs_work_order = create(
        :ncr_work_order,
        :with_approvers,
        org_code: Ncr::Organization::WHSC_CODE
      )
      whs_work_order.setup_approvals_and_observers

      approved_work_order = create(:ncr_work_order, :with_approvers)
      approved_work_order.setup_approvals_and_observers
      approved_work_order.individual_approvals.first.approve!

      alt_work_order = create(:ncr_work_order, :with_approvers)
      alt_work_order.setup_approvals_and_observers

      expect(Ncr::Reporter.proposals_tier_one_pending).to eq([approved_work_order.proposal])
    end
  end

  describe '.as_csv' do
    it "shows status-aware approver for approved work orders" do
      work_order = create(:ncr_work_order, :with_approvers)
      proposal = work_order.proposal
      while proposal.currently_awaiting_approvals.any?
        proposal.currently_awaiting_approvals.first.approve!
      end
      proposal.approve!
      proposal.reload
      expect(proposal.approved?).to be_truthy
      expect(work_order.final_approver).to eq(work_order.approvers.last)
      csv = Ncr::Reporter.as_csv([proposal])
      expect(csv).to include(",#{work_order.decorate.final_approver_email_address}")
    end
  end
end
