feature 'Approving an NCR work order' do
  let(:work_order)   { create(:ncr_work_order) }
  let(:ncr_proposal) { work_order.proposal }

  before do
    Timecop.freeze(10.hours.ago) do
      work_order.setup_approvals_and_observers
    end
    login_as(work_order.approvers.first)
  end

  scenario 'allows an approver to approve work order' do
    Timecop.freeze do
      visit "/proposals/#{ncr_proposal.id}"
      click_on('Approve')
      expect(current_path).to eq("/proposals/#{ncr_proposal.id}")
      expect(page).to have_content("You have approved #{work_order.public_identifier}")
      approval = Proposal.last.individual_approvals.first
      expect(approval.status).to eq('approved')
      expect(approval.approved_at.utc.to_s).to eq(Time.now.utc.to_s)
    end
  end

  scenario "doesn't send multiple emails to approvers who are also observers" do
    work_order.add_observer(work_order.approvers.first.email_address)
    visit "/proposals/#{ncr_proposal.id}"
    click_on('Approve')
    expect(work_order.proposal.observers.length).to eq(1)
    expect(deliveries.length).to eq(1)
  end
end
