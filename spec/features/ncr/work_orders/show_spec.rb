describe "viewing a work order" do
  let(:work_order)   { create(:ncr_work_order) }
  let(:ncr_proposal) { work_order.proposal }

  before do
    work_order.setup_approvals_and_observers
    login_as(work_order.requester)
  end

  it "shows a edit link from a pending proposal" do
    visit "/proposals/#{ncr_proposal.id}"
    expect(page).to have_content('MODIFY')
    expect(page).to have_selector('.edit-button', visible: true)
  end

  it "shows a edit link for a completed proposal" do
    # ncr_proposal.fully_complete!
    visit "/proposals/#{ncr_proposal.id}"
    expect(page).to have_content('MODIFY')
    expect(page).to have_selector('.edit-button', visible: true)
  end

  it "does not show a edit link for another client" do
    ncr_proposal.client_data = nil
    ncr_proposal.save
    visit "/proposals/#{ncr_proposal.id}"
    expect(page).not_to have_content('Modify Request')
  end

  it "does not show a edit link for non requester" do
    ncr_proposal.set_requester(create(:user, client_slug: "ncr"))
    visit "/proposals/#{ncr_proposal.id}"
    expect(page).not_to have_content('Modify Request')
  end

  it "doesn't show a edit/cancel/add observer link from a canceled proposal" do
    visit "/proposals/#{ncr_proposal.id}"
    expect(page).to have_content('Cancel request')
    ncr_proposal.update_attribute(:status, 'canceled')
    visit "/proposals/#{ncr_proposal.id}"
    expect(page).not_to have_content('Modify Request')
  end

  it "shows Emergency on non ba61 requests - (redesigned page)", :js do
    work_order_ba61 = create(:ba61_ncr_work_order, :with_beta_requester)
    login_as(work_order_ba61.requester)
    visit proposal_path(work_order_ba61.proposal)
    expect(page).to have_content('Emergency')
  end

  it "doesn't shows Emergency on non ba61 requests - (redesigned page)", :js do
    work_order_ba80 = create(:ba80_ncr_work_order, :with_beta_requester)
    work_order_ba80.save!
    login_as(work_order_ba80.requester)
    visit proposal_path(work_order_ba80.proposal)
    expect(page).to_not have_content('Emergency')
  end
end
