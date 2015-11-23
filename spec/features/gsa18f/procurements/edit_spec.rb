feature "Edit a Gsa18F procurement" do
  context "User is requester" do
    context "procurement has pending status" do
      scenario "can be modified" do
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

    scenario "can edit via link from proposal" do
      login_as(requester)
      visit proposal_path(proposal)

      click_on("Modify Request")

      expect(current_path).to eq(edit_gsa18f_procurement_path(procurement))
    end

    scenario "clicks update without changing any input" do
      login_as(requester)
      visit edit_gsa18f_procurement_path(procurement)

      click_on "Update"

      expect(page).to have_content("No changes were made to the request")
    end

    it "clicks discard changes link" do
      login_as(requester)
      visit edit_gsa18f_procurement_path(procurement)

      click_on "Discard Changes"

      expect(current_path).to eq(proposal_path(proposal))
    end

    context "Approved status" do
      scenario "cannot be restarted" do
        login_as(requester)
        proposal.update(status: "approved")

        visit edit_gsa18f_procurement_path(procurement)
        expect(current_path).to eq(new_gsa18f_procurement_path)
        expect(page).to have_content("already approved")
      end
    end

    context "Approved status" do
      scenario "modify link not shown" do
        proposal.update(status: "approved")
        login_as(requester)

        visit proposal_path(proposal)

        expect(page).not_to have_content("Modify Request")
      end
    end
  end

  context "User is not requester" do
    scenario "cannot be edited" do
      procurement.set_requester(create(:user))
      login_as(requester)

      visit edit_gsa18f_procurement_path(procurement)
      expect(current_path).to eq(new_gsa18f_procurement_path)
      expect(page).to have_content("You are not the requester")
    end
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
