describe Ncr::ApprovalManager do
  describe '#setup_approvals_and_observers' do
    let (:ba61_tier_one_email) { Ncr::Mailboxes.ba61_tier1_budget }
    let (:ba61_tier_two_email) { Ncr::Mailboxes.ba61_tier2_budget }

    it "creates approvers when not an emergency" do
      wo = create(:ncr_work_order, expense_type: 'BA61')
      manager = Ncr::ApprovalManager.new(wo)
      manager.setup_approvals_and_observers
      expect(wo.observations.length).to eq(0)
      expect(wo.approvers.map(&:email_address)).to eq([
        wo.approving_official_email,
        ba61_tier_one_email,
        ba61_tier_two_email
      ])
      wo.reload
      expect(wo.approved?).to eq(false)
    end

    it "reuses existing approvals" do
      wo = create(:ncr_work_order, expense_type: 'BA61')
      manager = Ncr::ApprovalManager.new(wo)
      manager.setup_approvals_and_observers
      first_approval = wo.individual_steps.first

      wo.reload.setup_approvals_and_observers
      expect(wo.individual_steps.first).to eq(first_approval)
    end

    it "creates observers when in an emergency" do
      wo = create(:ncr_work_order, expense_type: 'BA61',
                               emergency: true)
      manager = Ncr::ApprovalManager.new(wo)
      manager.setup_approvals_and_observers
      expect(wo.observers.map(&:email_address)).to match_array([
        wo.approving_official_email,
        ba61_tier_one_email,
        ba61_tier_two_email
      ].uniq)
      expect(wo.steps.length).to eq(0)
      wo.clear_association_cache
      expect(wo.approved?).to eq(true)
    end

    it "accounts for approver transitions when nothing's approved" do
      ba80_budget_email = Ncr::Mailboxes.ba80_budget
      wo = create(:ncr_work_order, approving_official_email: 'ao@example.com', expense_type: 'BA61')
      manager = Ncr::ApprovalManager.new(wo)
      manager.setup_approvals_and_observers
      expect(wo.approvers.map(&:email_address)).to eq [
        'ao@example.com',
        ba61_tier_one_email,
        ba61_tier_two_email
      ]

      wo.update(org_code: 'P1122021 (192X,192M) WHITE HOUSE DISTRICT')
      manager.setup_approvals_and_observers
      expect(wo.reload.approvers.map(&:email_address)).to eq [
        'ao@example.com',
        ba61_tier_two_email
      ]

      wo.approving_official_email = 'ao2@example.com'
      manager.setup_approvals_and_observers
      expect(wo.reload.approvers.map(&:email_address)).to eq [
        'ao2@example.com',
        ba61_tier_two_email
      ]

      wo.approving_official_email = 'ao@example.com'
      wo.update(expense_type: 'BA80')
      manager.setup_approvals_and_observers
      expect(wo.reload.approvers.map(&:email_address)).to eq [
        'ao@example.com',
        ba80_budget_email
      ]
    end

    it "unsets the approval status" do
      ba80_budget_email = Ncr::Mailboxes.ba80_budget
      wo = create(:ba80_ncr_work_order)
      manager = Ncr::ApprovalManager.new(wo)
      manager.setup_approvals_and_observers
      expect(wo.approvers.map(&:email_address)).to eq [
        wo.approving_official_email,
        ba80_budget_email
      ]

      wo.individual_steps.first.approve!
      wo.individual_steps.second.approve!
      expect(wo.reload.approved?).to be true

      wo.update(expense_type: 'BA61')
      manager.setup_approvals_and_observers
      expect(wo.reload.pending?).to be true
    end

    it "does not re-add observers on emergencies" do
      wo = create(:ncr_work_order, expense_type: 'BA61', emergency: true)
      manager = Ncr::ApprovalManager.new(wo)
      manager.setup_approvals_and_observers

      expect(wo.steps).to be_empty
      expect(wo.observers.count).to be 3

      manager.setup_approvals_and_observers
      wo.reload
      expect(wo.steps).to be_empty
      expect(wo.observers.count).to be 3
    end

    it "handles the delegate then update scenario" do
      wo = create(:ba80_ncr_work_order)
      manager = Ncr::ApprovalManager.new(wo)
      manager.setup_approvals_and_observers
      delegate = create(:user)
      wo.approvers.second.add_delegate(delegate)
      wo.individual_steps.second.update(user: delegate)

      wo.individual_steps.first.approve!
      wo.individual_steps.second.approve!

      manager.setup_approvals_and_observers
      wo.reload
      expect(wo.approved?).to be true
      expect(wo.approvers.second).to eq delegate
    end
  end

  describe '#system_approver_emails' do
    context "for a BA61 request" do
      let (:ba61_tier_one_email) { Ncr::Mailboxes.ba61_tier1_budget }
      let (:ba61_tier_two_email) { Ncr::Mailboxes.ba61_tier2_budget }

      it "skips the Tier 1 budget approver for WHSC" do
        work_order = create(:ncr_work_order, expense_type: 'BA61', org_code: Ncr::Organization::WHSC_CODE)
        manager = Ncr::ApprovalManager.new(work_order)
        expect(manager.system_approver_emails).to eq([
          ba61_tier_two_email
        ])
      end

      it "includes the Tier 1 budget approver for an unknown organization" do
        work_order = create(:ncr_work_order, expense_type: 'BA61', org_code: nil)
        manager = Ncr::ApprovalManager.new(work_order)
        expect(work_order.system_approver_emails).to eq([
          ba61_tier_one_email,
          ba61_tier_two_email
        ])
      end
    end

    context "for a BA80 request" do
      it "uses the general budget email" do
        ba80_budget_email = Ncr::Mailboxes.ba80_budget
        work_order = create(:ba80_ncr_work_order)
        manager = Ncr::ApprovalManager.new(work_order)
        expect(manager.system_approver_emails).to eq([ba80_budget_email])
      end

      it "uses the OOL budget email for their org code" do
        budget_email = Ncr::Mailboxes.ool_ba80_budget
        org_code = Ncr::Organization::OOL_CODES.first

        work_order = create(:ba80_ncr_work_order, org_code: org_code)
        manager = Ncr::ApprovalManager.new(work_order)
        expect(manager.system_approver_emails).to eq([budget_email])
      end
    end
  end
end
