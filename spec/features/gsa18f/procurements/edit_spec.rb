feature "Edit a Gsa18F procurement" do
  context "User is requester" do
    context "procurement has pending status" do
      scenario "can be modified" do
        requester = create(:user, client_slug: "gsa18f")
        procurement = create(:gsa18f_procurement, :with_steps, requester: requester, urgency: 10)
        proposal = procurement.proposal

        login_as(requester)
        visit edit_gsa18f_procurement_path(procurement)

        fill_in "Link to product", with: "http://www.submitted.com"
        fill_in "Cost per unit", with: 123.45
        fill_in "Quantity", with: 1
        fill_in "Product name and description", with: "resubmitted"
        click_on "Update"

        expect(current_path).to eq(proposal_path(proposal))
        expect(page).to have_content("http://www.submitted.com")
        expect(page).to have_content("resubmitted")
      end
    end

    scenario "clicks CANCEL without changing any input", :js do
      requester = create(:user, client_slug: "gsa18f")
      procurement = create(:gsa18f_procurement, :with_steps, requester: requester, urgency: 10)

      login_as(requester)
      visit proposal_path(procurement.proposal)

      click_on "MODIFY"
      click_on "CANCEL"

      expect(page).to have_content("Modification canceled. No changes were made.")
    end

    it "clicks discard changes link" do
      requester = create(:user, client_slug: "gsa18f")
      procurement = create(:gsa18f_procurement, :with_steps, requester: requester, urgency: 10)
      proposal = procurement.proposal

      login_as(requester)
      visit edit_gsa18f_procurement_path(procurement)

      click_on "Discard Changes"

      expect(current_path).to eq(proposal_path(proposal))
    end

    context "Approved status" do
      scenario "modify link not shown" do
        requester = create(:user, client_slug: "gsa18f")
        procurement = create(:gsa18f_procurement, :with_steps, requester: requester, urgency: 10)
        proposal = procurement.proposal

        proposal.update(status: "completed")
        login_as(requester)

        visit proposal_path(proposal)

        expect(page).not_to have_content("Modify Request")
      end
    end
  end

  context "User is not requester" do
    scenario "cannot be edited", :js do
      requester = create(:user, client_slug: "gsa18f")
      procurement = create(:gsa18f_procurement, :with_steps, requester: requester, urgency: 10)
      proposal = procurement.proposal

      procurement.set_requester(create(:user))
      login_as(requester)

      visit proposal_path(proposal)
      expect(page).not_to have_content("MODIFY")
    end
  end
end
