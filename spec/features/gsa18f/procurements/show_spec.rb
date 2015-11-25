feature "View Gsa18F procurement" do
  scenario "requester can see procurement details" do
    login_as(requester)

    visit proposal_path(proposal)

    expect(page).to have_content(procurement.purchase_type)
  end

  def requester
    @_requester ||= create(:user, client_slug: "gsa18f")
  end

  def procurement
    @_procurement ||= create(:gsa18f_procurement, :with_steps, requester: requester, urgency: 10)
  end

  def proposal
    @_proposal ||= procurement.proposal
  end
end
