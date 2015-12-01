feature 'Requester switches work order to WHSC' do
  let(:work_order) { create(:ncr_work_order, org_code: Ncr::Organization.all.first.to_s, description: 'test') }
  let(:ncr_proposal) { work_order.proposal }
  let!(:approver) { create(:user) }

  before do
    work_order.setup_approvals_and_observers
    work_order.individual_steps.first.approve!
    login_as(work_order.requester)
  end

  context 'as a BA61' do
    scenario 'reassigns the approvers properly' do
      expect(work_order.ncr_organization).to_not be_whsc
      approving_official = work_order.approving_official

      visit "/ncr/work_orders/#{work_order.id}/edit"
      select Ncr::Organization::WHSC_CODE, from: "Org Code / Service Center"
      click_on 'Update'

      ncr_proposal.reload
      work_order.reload

      expect(ncr_proposal.approvers.map(&:email_address)).to eq([
        approving_official.email_address,
        Ncr::Mailboxes.ba61_tier2_budget
      ])
      expect(work_order.individual_steps.first).to be_approved
      expect(work_order.individual_steps.second).to be_actionable
    end

    scenario 'notifies the removed approver' do
      expect(work_order.ncr_organization).to_not be_whsc
      deliveries.clear

      visit "/ncr/work_orders/#{work_order.id}/edit"
      select Ncr::Organization::WHSC_CODE, from: "Org Code / Service Center"
      click_on 'Update'

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
      work_order = create(:ba80_ncr_work_order, org_code: Ncr::Organization.all[0].to_s)
      work_order.setup_approvals_and_observers
      work_order.individual_steps.first.approve!
      expect(work_order.ncr_organization).to_not be_whsc
      ncr_proposal = work_order.proposal

      approving_official = work_order.approving_official

      login_as(work_order.requester)
      visit "/ncr/work_orders/#{work_order.id}/edit"
      choose "BA61"
      select Ncr::Organization::WHSC_CODE, from: "Org Code / Service Center"
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
