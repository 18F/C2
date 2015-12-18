feature "Proposals index" do
  include ProposalTableSpecHelper

  scenario "filters pending proposals according to current_user" do
    user = create(:user)
    _reviewable_proposals = create_list(:proposal, 2, observer: user)
    _pending_proposals = create_list(:proposal, 2, :with_approver, approver_user: user)
    _cancelled = create_list(:proposal, 2, status: "cancelled", observer: user)

    login_as(user)
    visit proposals_path
    tables = page.all('.tabular-data')

    expect(tables[0].text).to have_content('Please review')
    expect(tables[1].text).to have_content('Waiting for review')
    expect(tables[2].text).to have_content('Cancelled')
  end

  scenario "defaults to sorted by created date" do
    user = create(:user)
    proposals = create_list(:proposal, 2, observer: user)
    cancelled = create_list(:proposal, 2, status: "cancelled", observer: user)
    @page = MyRequestsPage.new

    login_as(user)
    @page.load

    expect(@page.pending.desc_column_header).to have_content "Submitted"
    expect(@page.cancelled.desc_column_header).to have_content "Submitted"

    expect_order(@page.pending, proposals.reverse)
    expect_order(@page.cancelled, cancelled.reverse)
  end

  describe "status field text" do
    context "when the user is an approver or purchaser" do
      it "is correct for the user" do
        user = create(:user)
        other_user = create(:user)
        approval_proposal = create_proposal_with_approvers(user, other_user)
        purchase_proposal = create_proposal_with_approvers(other_user, user)
        purchase_proposal.individual_steps.first.approve!
        @page = MyRequestsPage.new

        login_as(user)
        @page.load

        expect(@page.needing_review.requests[1].public_id_link.text).to eq approval_proposal.public_id
        expect(@page.needing_review.requests[1].status.text).to eq "Please review"
        expect(@page.needing_review.requests[0].public_id_link.text).to eq purchase_proposal.public_id
        expect(@page.needing_review.requests[0].status.text).to eq "Please purchase"
      end
    end

    context "when the user's request is waiting for approval or purchase" do
      it "is correct for the user" do
        user = create(:user)
        approver = create(:user)
        purchaser = create(:user)
        approval_proposal = create_proposal_for_requester_with_approvers(user, approver, purchaser)
        purchase_proposal = create_proposal_for_requester_with_approvers(user, approver, purchaser)
        purchase_proposal.individual_steps.first.approve!
        @page = MyRequestsPage.new

        login_as(user)
        @page.load

        expect(@page.pending.requests[1].public_id_link.text).to eq approval_proposal.public_id
        expect(@page.pending.requests[1].status.text).to eq "Waiting for review from: #{approver.full_name}"
        expect(@page.pending.requests[0].public_id_link.text).to eq purchase_proposal.public_id
        expect(@page.pending.requests[0].status.text).to eq "Waiting for purchase from: #{purchaser.full_name}"
      end
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

  def create_proposal_for_requester_with_approvers(requester, first_approver, second_approver)
    proposal = create_proposal_with_approvers(first_approver, second_approver)
    proposal.update(requester: requester)
    proposal
  end
end
