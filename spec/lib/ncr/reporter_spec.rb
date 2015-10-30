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

      user = create(:user, email_address: Ncr::WorkOrder::NCR_BA61_TIER1_BUDGET_APPROVER_MAILBOX)
      role = create(:role, name: "BA61_tier1_budget_approver")
      user.roles << role

      approved_work_order = create(:ncr_work_order, :with_approvers, expense_type: "BA61")
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

  describe "#build_ncr_annual_report_string" do
    it "includes information about cancelled NCR work orders for fiscal year passed in" do
      Timecop.freeze do
        current_year = Time.now.year
        beginning_of_year = Time.now.beginning_of_year
        approved_proposal = create(:proposal, status: "approved")
        cancelled_proposal = create(:proposal, status: "cancelled")
        approved_work_order = create(
          :ncr_work_order,
          amount: 100,
          description: "an approved work order",
          created_at: beginning_of_year,
          proposal: approved_proposal
        )
        cancelled_work_order = create(
          :ncr_work_order,
          amount: 200,
          description: "a canclled work order",
          created_at: beginning_of_year,
          proposal: cancelled_proposal
        )

        csv = Ncr::Reporter.new.build_ncr_annual_report_string(current_year)

        expect(csv).to include(cancelled_work_order.amount.to_s)
        expect(csv).not_to include(approved_work_order.amount.to_s)
        expect(csv).to include(cancelled_work_order.description)
        expect(csv).not_to include(approved_work_order.description)
      end
    end
  end
end
