describe Ncr::WorkOrderUpdater do
  describe ".run" do
    it "sends an on_proposal_update email" do
      work_order = create(:ncr_work_order)
      comment = create_comment(work_order)
      work_order.modifier = work_order.requester
      stub_reapproval_checker_and_return(false, work_order)
      allow(work_order).to receive(:setup_approvals_and_observers)
      dispatch_double = double(on_proposal_update: false)
      allow(DispatchFinder).to receive(:run).with(work_order.proposal).and_return(dispatch_double)

      Ncr::WorkOrderUpdater.new(
        work_order: work_order,
        update_comment: comment
      ).run

      expect(dispatch_double).to have_received(:on_proposal_update).with(
        modifier: work_order.requester,
        needs_review: false,
        comment: comment
      )
    end

    context "reapproval necessary" do
      it "restarts budget approvals" do
        work_order = create(:ncr_work_order, :with_observers)
        comment = create_comment(work_order)
        stub_reapproval_checker_and_return(true, work_order)
        allow(work_order).to receive(:restart_budget_approvals)

        Ncr::WorkOrderUpdater.new(
          work_order: work_order,
          update_comment: comment
        ).run

        expect(work_order).to have_received(:restart_budget_approvals)
      end
    end

    context "reapproval not necessary" do
      it "does not restart budget approvals" do
        work_order = create(:ncr_work_order)
        stub_reapproval_checker_and_return(false, work_order)
        comment = create_comment(work_order)
        allow(work_order).to receive(:restart_budget_approvals)

        Ncr::WorkOrderUpdater.new(
          work_order: work_order,
          update_comment: comment
        ).run

        expect(work_order).not_to have_received(:restart_budget_approvals)
      end
    end
  end

  def stub_reapproval_checker_and_return(value, work_order)
    checker_double = double(requires_budget_reapproval?: value)
    allow(Ncr::WorkOrderReapprovalChecker).to receive(:new).with(work_order).
      and_return(checker_double)
  end

  def create_comment(work_order)
    @_comment ||= create(
      :comment,
      update_comment: true,
      user: work_order.requester,
      proposal: work_order.proposal
    )
  end
end
