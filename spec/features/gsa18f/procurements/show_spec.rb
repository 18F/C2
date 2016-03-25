feature "View Gsa18F procurement" do
  let(:requester) { create(:user, client_slug: "gsa18f") }
  let(:procurement) { create(:gsa18f_procurement, :with_steps, requester: requester, urgency: 10) }
  let(:proposal) { procurement.proposal }

  scenario "requester can see procurement details" do
    login_as(requester)

    visit proposal_path(proposal)

    expect(page).to have_content(procurement.purchase_type)
  end
end
