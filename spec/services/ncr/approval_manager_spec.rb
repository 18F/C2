describe Ncr::ApprovalManager do
  describe '#setup_approvals_and_observers' do
    let(:ba61_tier_one) { Ncr::Mailboxes.ba61_tier1_budget }
    let(:ba61_tier_two) { Ncr::Mailboxes.ba61_tier2_budget }

    it "creates approvers when not an emergency" do
      wo = create(:ncr_work_order, expense_type: "BA61")
      manager = Ncr::ApprovalManager.new(wo)
      manager.setup_approvals_and_observers
      expect(wo.observations.length).to eq(0)
      expect(wo.approvers).to eq([wo.approving_official])
      wo.reload
      expect(wo.completed?).to eq(false)
    end

    it "replaces approving official step when approving official changed to system approver delegate" do
      new_user = create(:user)
      user = create(:user)
      work_order = create(:ncr_work_order, approving_official: user)
      Ncr::ApprovalManager.new(work_order).setup_approvals_and_observers
      create(:user_delegate, assignee: new_user, assigner: work_order.proposal.individual_steps.last.user)
      work_order.update(approving_official: new_user)
      Ncr::ApprovalManager.new(work_order).setup_approvals_and_observers

      expect(work_order.proposal.individual_steps.count).to eq 2
      expect(work_order.proposal.steps.where(user: user)).not_to be_present
      expect(work_order.proposal.steps.where(user: new_user)).to be_present
    end

    it "reuses existing approvals" do
      wo = create(:ncr_work_order, expense_type: "BA61")
      manager = Ncr::ApprovalManager.new(wo)
      manager.setup_approvals_and_observers
      root_step = wo.proposal.root_step
      first_approval = wo.individual_steps.first

      wo.reload.setup_approvals_and_observers
      expect(wo.individual_steps.first).to eq(first_approval)
      expect(wo.proposal.root_step).to eq(root_step)
    end

    it "creates observers when in an emergency" do
      wo = create(:ncr_work_order, expense_type: "BA61", emergency: true)
      manager = Ncr::ApprovalManager.new(wo)
      manager.setup_approvals_and_observers
      expect(wo.observers).to match_array([
        wo.approving_official
      ].uniq)
      expect(wo.steps.length).to eq(0)
      wo.clear_association_cache
      expect(wo.completed?).to eq(true)
    end

    it "accounts for approver transitions when nothing's completed" do
      email = "ao@example.com"
      approving_official = create(:user, email_address: email)
      organization = create(:whsc_organization)
      ba80_budget = Ncr::Mailboxes.ba80_budget
      wo = create(
        :ncr_work_order,
        approving_official: approving_official,
        expense_type: "BA61",
      )
      manager = Ncr::ApprovalManager.new(wo)
      manager.setup_approvals_and_observers
      expect(wo.approvers).to eq [approving_official]

      wo.update(ncr_organization: organization)
      manager.setup_approvals_and_observers
      expect(wo.reload.approvers).to eq [approving_official]

      approving_official_2 = create(:user, email_address: "ao2@example.com")
      wo.update(approving_official: approving_official_2)
      manager.setup_approvals_and_observers
      expect(wo.reload.approvers).to eq [approving_official_2]

      wo.update(approving_official: approving_official)
      wo.update(expense_type: "BA80")
      manager.setup_approvals_and_observers
      expect(wo.reload.approvers).to eq [
        approving_official,
        ba80_budget
      ]
    end

    describe "when changing expense type on a proposal which has only been approved by the approving official" do
      context "from one with budget approvers to one without" do
        it "changes the approval status" do
          ba80_budget = Ncr::Mailboxes.ba80_budget
          wo = create(:ba80_ncr_work_order)
          manager = Ncr::ApprovalManager.new(wo)
          manager.setup_approvals_and_observers
          expect(wo.approvers).to eq [
            wo.approving_official,
            ba80_budget
          ]

          wo.individual_steps.first.complete!
          expect(wo.reload.completed?).to be false

          wo.update(expense_type: "BA61")
          manager.setup_approvals_and_observers
          expect(wo.reload.completed?).to be true
        end
      end
    end

    it "does not re-add observers on emergencies" do
      wo = create(:ncr_work_order, expense_type: "BA61", emergency: true)
      manager = Ncr::ApprovalManager.new(wo)
      manager.setup_approvals_and_observers

      expect(wo.steps).to be_empty
      expect(wo.observers.count).to be 1

      manager.setup_approvals_and_observers
      wo.reload
      expect(wo.steps).to be_empty
      expect(wo.observers.count).to be 1
    end

    it "handles the delegate then update scenario" do
      wo = create(:ba80_ncr_work_order)
      manager = Ncr::ApprovalManager.new(wo)
      manager.setup_approvals_and_observers
      delegate_user = create(:user)
      wo.approvers.second.add_delegate(delegate_user)
      wo.individual_steps.second.update(completer: delegate_user)

      wo.individual_steps.first.complete!
      wo.individual_steps.second.complete!

      manager.setup_approvals_and_observers
      wo.reload
      expect(wo.completed?).to be true
      expect(wo.individual_steps.second.completer).to eq delegate_user
    end
  end

  describe '#system_approvers' do
    context "for a BA61 request" do
      let(:ba61_tier_one) { Ncr::Mailboxes.ba61_tier1_budget }
      let(:ba61_tier_two) { Ncr::Mailboxes.ba61_tier2_budget }

      context "when budget approvers are automatically added" do
        it "skips the Tier 1 budget approver for WHSC" do
          ncr_organization = create(:whsc_organization)
          work_order = create(
            :ncr_work_order,
            expense_type: "BA61",
            ncr_organization: ncr_organization
          )
          manager = Ncr::ApprovalManager.new(work_order)
          allow(manager).to receive(:should_add_budget_approvers_to_6x?).and_return(true)
          expect(manager.system_approvers).to eq([
                                                   ba61_tier_two
                                                 ])
        end

        it "includes the Tier 1 budget approver for an unknown organization" do
          work_order = create(:ncr_work_order, expense_type: "BA61")
          manager = Ncr::ApprovalManager.new(work_order)
          allow(manager).to receive(:should_add_budget_approvers_to_6x?).and_return(true)
          expect(manager.system_approvers).to eq([
                                                   ba61_tier_one,
                                                   ba61_tier_two
                                                 ])
        end
      end

      context "when budget approvers are not automatically added" do
        it "does not include any budget approvers" do
          work_order = create(:ncr_work_order, expense_type: "BA61")
          manager = Ncr::ApprovalManager.new(work_order)
          allow(manager).to receive(:should_add_budget_approvers_to_6x?).and_return(false)
          expect(manager.system_approvers).to eq([])
        end
      end
    end

    context "for a BA80 request" do
      it "uses the general budget email" do
        ba80_budget = Ncr::Mailboxes.ba80_budget
        work_order = create(:ba80_ncr_work_order)
        manager = Ncr::ApprovalManager.new(work_order)
        expect(manager.system_approvers).to eq([ba80_budget])
      end

      it "uses the OOL budget email for their org code" do
        budget = Ncr::Mailboxes.ool_ba80_budget
        ool_organization = create(:ool_organization)
        work_order = create(:ba80_ncr_work_order, ncr_organization: ool_organization)

        manager = Ncr::ApprovalManager.new(work_order)
        expect(manager.system_approvers).to eq([budget])
      end
    end
  end

  describe "#should_add_budget_approvers_to_6x?" do
    before(:each) { @manager = Ncr::ApprovalManager.new(nil) }

    it "returns true before July 5 2016" do
      Timecop.freeze("2016-07-04 16:55".in_time_zone("America/New_York")) do
        # binding.pry
        expect(@manager.should_add_budget_approvers_to_6x?).to be true
      end
    end

    it "returns false on or after July 5 2016" do
      Timecop.freeze("2016-07-05 08:00".in_time_zone("America/New_York")) do
        expect(@manager.should_add_budget_approvers_to_6x?).to be false
      end
    end
  end
end
