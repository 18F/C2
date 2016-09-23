feature "View Gsa18F procurement" do
  scenario "requester can see procurement details" do
    requester = create(:user, client_slug: "gsa18f")
    procurement = create(:gsa18f_procurement, :with_steps, requester: requester, urgency: 10)
    proposal = procurement.proposal

    login_as(requester)

    visit proposal_path(proposal)

    expect(page).to have_content(procurement.purchase_type)
  end

  scenario "last step is completed" do
    it "shows the pegasys document number" do
      purchaser = Gsa18f::Procurement.user_with_role("gsa18f_purchaser")
      procurement = create(:gsa18f_procurement, :with_steps)
      proposal = procurement.proposal

      procurement.individual_steps.first.complete!
      deliveries.clear

      login_as(purchaser)
      visit proposal_path(proposal)
      expect(page).not_to have_content("Pegasys Document Number")
      click_on("Mark as Purchased")

      visit proposal_path(proposal)
      expect(page).to have_content("Pegasys Document Number")

    end
  end
end
