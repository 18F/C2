feature "My requests needing action" do

  feature "The 'My Requests' page 'needing action' section" do
    scenario "contains requests that can be acted on by the user" do
      purchaser_user = create(:user)
      request_needing_purchase = create_proposal_with_approvers(create(:user), purchaser_user)
      request_needing_purchase.individual_steps.first.approve!

      login_as(purchaser_user)
      @page = ProposalIndexPage.new
      @page.load
      needing_review_section = @page.needing_review

      expect(needing_review_section.requests.first.public_id_link.text).to eq request_needing_purchase.public_id
    end

    scenario "does not contain requests that cannot be acted on by the user" do
      purchaser_user = create(:user)
      request_needing_approval = create_proposal_with_approvers(create(:user), purchaser_user)

      login_as(purchaser_user)
      @page = ProposalIndexPage.new
      @page.load
      needing_review_section = @page.needing_review

      expect(needing_review_section.requests).to be_empty
    end
  end

  def create_proposal_with_approvers(first_approver, second_approver)
    proposal = create(:proposal)
    steps = [
      create(:approval, user: first_approver),
      create(:purchase_step, user: second_approver)
    ]
    proposal.add_initial_steps(steps)
    proposal
  end
end
