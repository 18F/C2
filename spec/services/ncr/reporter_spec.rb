describe Ncr::Reporter do
  before(:all) do
    ENV["DISABLE_EMAIL"] = "Yes"
    @work_order           = create(:ncr_work_order, :with_approvers)
    @completed_work_order = create(:ncr_work_order, :with_approvers).tap(&:setup_approvals_and_observers)
  end

  after(:all) do
    ENV["DISABLE_EMAIL"] = nil
  end

  describe "#proposals_pending_approving_official" do
    it "only returns Proposals where the approving official is actionable" do
      @work_order.individual_steps.first.complete!

      expect(Ncr::Reporter.proposals_pending_approving_official).to include(@completed_work_order.proposal)
      expect(Ncr::Reporter.proposals_pending_approving_official).not_to include(@work_order.proposal)
    end
  end

  describe "#proposals_pending_budget" do
    it "only returns Proposals where the budget approver is actionable" do
      actionable = create(:ncr_work_order, :with_approvers)
      # all but the last
      actionable.individual_steps[0...-1].each(&:complete!)

      expect(Ncr::Reporter.proposals_pending_budget).to eq([actionable.proposal])
    end
  end

  describe "#proposals_tier_one_pending" do
    it "only returns Proposals where Tier One approval is actionable" do
      @completed_work_order.individual_steps.first.complete!

      expect(Ncr::Reporter.proposals_tier_one_pending).to eq([@completed_work_order.proposal])
    end
  end

  describe "#as_csv" do
    it "shows final approver for completed work orders" do
      proposal = @completed_work_order.proposal
      while proposal.currently_awaiting_steps.any?
        proposal.currently_awaiting_steps.first.complete!
      end
      proposal.complete!
      proposal.reload
      expect(proposal).to be_completed
      expect(@completed_work_order.final_approver).to eq(@completed_work_order.approvers.last)

      csv = Ncr::Reporter.as_csv([proposal])
      expect(csv).to include(",#{@completed_work_order.decorate.current_approver_email_address}")
    end

    it "shows current approver for pending work orders" do
      work_order = create(:ncr_work_order, :with_approvers)
      work_order.setup_approvals_and_observers
      proposal = work_order.proposal

      individual_approval_step = proposal.currently_awaiting_steps.first
      expect(work_order.current_approver).to eq(individual_approval_step.user)
      csv = Ncr::Reporter.as_csv([proposal]) # Crashing, nil error
      expect(csv).to include(",#{individual_approval_step.user.email_address}")

      individual_approval_step.complete!
      official_approval_step = proposal.currently_awaiting_steps.first
      proposal.reload
      work_order.reload
      expect(work_order.current_approver).to eq(official_approval_step.user)
      csv = Ncr::Reporter.as_csv([proposal])
      expect(csv).to include(",#{official_approval_step.user.email_address}")

      official_approval_step.complete!
      budget_approval_step = proposal.currently_awaiting_steps.first
      proposal.reload
      work_order.reload
      expect(work_order.current_approver).to eq(budget_approval_step.user)
      csv = Ncr::Reporter.as_csv([proposal])
      expect(csv).to include(",#{budget_approval_step.user.email_address}")
    end

    it "shows final completed date and completion duration in days" do
      proposal = @completed_work_order.proposal
      while proposal.currently_awaiting_steps.any?
        proposal.currently_awaiting_steps.first.complete!
      end
      proposal.complete!
      proposal.reload
      expect(proposal).to be_completed
      expect(@completed_work_order.final_approver).to eq(@completed_work_order.approvers.last)
      csv = Ncr::Reporter.as_csv([proposal])
      expect(csv).to include(",#{proposal.decorate.final_completed_date},#{proposal.decorate.total_completion_days}")
    end
  end

  describe "#build_fiscal_year_report_string" do
    it "includes information about approved NCR work orders for fiscal year passed in" do
      Timecop.freeze do
        current_year = Time.zone.now.year
        beginning_of_year = Time.zone.now.beginning_of_year
        completed_proposal = create(:proposal, status: "completed")
        canceled_proposal = create(:proposal, status: "canceled")
        completed_work_order = create(
          :ncr_work_order,
          amount: 100,
          description: "an approved work order",
          created_at: beginning_of_year,
          proposal: completed_proposal
        )
        canceled_work_order = create(
          :ncr_work_order,
          amount: 200,
          description: "a canclled work order",
          created_at: beginning_of_year,
          proposal: canceled_proposal
        )

        csv = Ncr::Reporter.new.build_fiscal_year_report_string(current_year)

        expect(csv).to include(completed_work_order.amount.to_s)
        expect(csv).not_to include(canceled_work_order.amount.to_s)
        expect(csv).to include(completed_work_order.description)
        expect(csv).not_to include(canceled_work_order.description)
      end
    end
  end
end
