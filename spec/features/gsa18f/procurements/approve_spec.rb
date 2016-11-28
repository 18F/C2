feature "Approve a Gsa18F procurement" do
  context "when signed in as the approver" do
    context "last step is completed" do
      it "sends one email to the requester", :email do
        purchaser = Gsa18f::Procurement.user_with_role("gsa18f_purchaser")
        procurement = create(:gsa18f_procurement, :with_steps)
        proposal = procurement.proposal

        procurement.individual_steps.first.complete!
        deliveries.clear

        login_as(purchaser)
        visit proposal_path(proposal)
        click_on("Mark as Purchased")

        expect(deliveries.length).to eq(1)
        expect(deliveries.first.to).to eq([proposal.requester.email_address])
      end
    end

    it "the step execution button is correctly marked" do
      approver = Gsa18f::Procurement.user_with_role("gsa18f_approver")
      proposal = create(:gsa18f_procurement, :with_steps).proposal

      login_as(approver)

      visit proposal_path(proposal)

      expect(page).to have_button("Approve")
    end

    it "shows a cancel link for approver" do
      approver = Gsa18f::Procurement.user_with_role("gsa18f_approver")
      proposal = create(:gsa18f_procurement, :with_steps).proposal

      login_as(approver)

      visit proposal_path(proposal)

      expect(page).to have_content("Cancel request")
    end
  end

  context "when signed in as the purchaser" do
    it "the step execution button is correctly marked" do
      approver = Gsa18f::Procurement.user_with_role("gsa18f_approver")
      purchaser = Gsa18f::Procurement.user_with_role("gsa18f_purchaser")
      proposal = create(:gsa18f_procurement, :with_steps).proposal

      login_as(approver)
      visit proposal_path(proposal)
      click_on "Approve"

      login_as(purchaser)
      visit proposal_path(proposal)

      expect(page).to have_button("Mark as Purchased")
    end

    it "does not show a cancel link for purchaser" do
      purchaser = Gsa18f::Procurement.user_with_role("gsa18f_purchaser")
      proposal = create(:gsa18f_procurement, :with_steps).proposal

      login_as(purchaser)

      visit proposal_path(proposal)

      expect(page).to_not have_content("Cancel this request")
    end
  end
end
