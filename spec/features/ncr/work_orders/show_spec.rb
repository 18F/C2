describe "viewing a work order" do
  let(:work_order)   { create(:ncr_work_order) }
  let(:ncr_proposal) { work_order.proposal }

  before do
    work_order.setup_approvals_and_observers
    login_as(work_order.requester)
  end

  it "shows a edit link from a pending proposal" do
    @page = get_proposal_page(ncr_proposal.id)
    expect(@page).to have_edit_button
  end

  it "shows a edit link for a completed proposal" do
    ncr_proposal.update(status: "completed") # avoid state machine

    @page = get_proposal_page(ncr_proposal.id)
    expect(@page).to have_edit_button
  end

  it "does not show a edit link for another client" do
    ncr_proposal.client_data = nil
    ncr_proposal.save
    @page = get_proposal_page(ncr_proposal.id)
    expect(@page).not_to have_edit_button
  end

  it "does not show a edit link for non requester" do
    ncr_proposal.set_requester(create(:user, client_slug: "ncr"))
    @page = get_proposal_page(ncr_proposal.id)
    expect(@page).not_to have_edit_button
  end

  it "doesn't show a edit/cancel/add observer link from a canceled proposal" do
    @page = get_proposal_page(ncr_proposal.id)
    expect(@page).to have_cancel_button
    ncr_proposal.update_attribute(:status, 'canceled')
    @page.load(proposal_id: ncr_proposal.id)
    expect(@page).not_to have_edit_button
  end
end

def get_proposal_page(id)
  page = ProposalPage.new
  page.load(proposal_id: id)
  page
end
