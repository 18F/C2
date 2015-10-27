describe Ncr::ApprovalManager do
  describe '#system_approver_emails' do
    context "for a BA61 request" do
      let (:ba61_tier_one_email) { Ncr::ApprovalManager.ba61_tier1_budget_mailbox }
      let (:ba61_tier_two_email) { Ncr::ApprovalManager.ba61_tier2_budget_mailbox }

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
        ba80_budget_email = Ncr::ApprovalManager.ba80_budget_mailbox
        work_order = create(:ncr_work_order, expense_type: 'BA80')
        manager = Ncr::ApprovalManager.new(work_order)
        expect(manager.system_approver_emails).to eq([ba80_budget_email])
      end

      it "uses the OOL budget email for their org code" do
        budget_email = Ncr::ApprovalManager.ool_ba80_budget_mailbox
        org_code = Ncr::Organization::OOL_CODES.first

        work_order = create(:ncr_work_order, expense_type: 'BA80', org_code: org_code)
        manager = Ncr::ApprovalManager.new(work_order)
        expect(manager.system_approver_emails).to eq([budget_email])
      end
    end
  end
end
