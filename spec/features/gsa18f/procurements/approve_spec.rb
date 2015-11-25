feature "Approve a Gsa18F procurement" do
  context "when signed in as the approver" do
    it "the step execution button is correctly marked" do
      login_as(approver)

      visit proposal_path(proposal)

      expect(page).to have_button("Approve")
    end

    it "shows a cancel link for approver" do
      login_as(approver)

      visit proposal_path(proposal)

      expect(page).to have_content("Cancel this request")
    end
  end

  context "when signed in as the purchaser" do
    it "the step execution button is correctly marked" do
      login_as(approver)
      visit proposal_path(proposal)
      click_on "Approve"

      login_as(purchaser)
      visit proposal_path(proposal)

      expect(page).to have_button("Mark as Purchased")
    end

    it "does not show a cancel link for purchaser" do
      login_as(purchaser)

      visit proposal_path(proposal)

      expect(page).to_not have_content("Cancel this request")
    end
  end

  def approver
    @_approver ||= Gsa18f::Procurement.user_with_role("gsa18f_approver")
  end

  def purchaser
    @_purchaser ||= Gsa18f::Procurement.user_with_role("gsa18f_purchaser")
  end

  def proposal
    @_proposal ||= procurement.proposal
  end

  def procurement
    @_procurement ||= create(:gsa18f_procurement, :with_steps)
  end
end
