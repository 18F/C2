feature "Requester switches work order to WHSC" do
  let(:work_order) do
    create(:ncr_work_order, ncr_organization: create(:ncr_organization))
  end

  let(:ncr_proposal) { work_order.proposal }
  let!(:approver) { create(:user) }

  before do
    work_order.setup_approvals_and_observers
    work_order.individual_steps.first.approve!
    login_as(work_order.requester)
  end

  context "as a BA61" do
    scenario "reassigns the approvers properly" do
      whsc_org = create(:whsc_organization)
      expect(work_order.ncr_organization).to_not be_whsc
      approving_official = work_order.approving_official

      visit edit_ncr_work_order_path(work_order)
      select whsc_org.code_and_name, from: "ncr_work_order[ncr_organization_id]"
      click_on "Update"

      ncr_proposal.reload
      work_order.reload

      expect(ncr_proposal.approvers.map(&:email_address)).to eq([
        approving_official.email_address,
        Ncr::Mailboxes.ba61_tier2_budget
      ])
      expect(work_order.individual_steps.first).to be_approved
      expect(work_order.individual_steps.second).to be_actionable
    end

    scenario "notifies the removed approver" do
      whsc_org = create(:whsc_organization)
      expect(work_order.ncr_organization).to_not be_whsc
      deliveries.clear

      visit edit_ncr_work_order_path(work_order)
      select whsc_org.code_and_name, from: "ncr_work_order[ncr_organization_id]"
      click_on "Update"

      expect(deliveries.length).to be 3
      removed, approver1, approver2 = deliveries
      expect(removed.to).to eq([Ncr::Mailboxes.ba61_tier1_budget])
      expect(removed.html_part.body).to include "removed"

      expect(approver1.to).to eq([work_order.approvers.first.email_address])
      expect(approver1.html_part.body).not_to include "removed"
      expect(approver2.to).to eq([Ncr::Mailboxes.ba61_tier2_budget])
      expect(approver2.html_part.body).not_to include "removed"
    end
  end

  context "as a BA80" do
    scenario "reassigns the approvers properly" do
      whsc_org = create(:whsc_organization)
      work_order = create(:ba80_ncr_work_order)
      work_order.setup_approvals_and_observers
      work_order.individual_steps.first.approve!
      ncr_proposal = work_order.proposal

      approving_official = work_order.approving_official

      login_as(work_order.requester)
      visit edit_ncr_work_order_path(work_order)
      choose "BA61"
      select whsc_org.code_and_name, from: "ncr_work_order[ncr_organization_id]"
      click_on "Update"

      ncr_proposal.reload
      work_order.reload

      expect(ncr_proposal.approvers.map(&:email_address)).to eq([
        approving_official.email_address,
        Ncr::Mailboxes.ba61_tier2_budget
      ])
      expect(work_order.individual_steps.first).to be_approved
    end
  end
end
