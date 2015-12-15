require 'pry'

describe "My requests needing action" do

  describe "The 'My Requests' page 'needing action' section" do
    let(:approver_user)  { create(:user) }
    let(:purchaser_user) { create(:user) }
    let!(:request_needing_approval) { create_proposal_with_approvers(approver_user, purchaser_user) }
    let!(:request_needing_purchase) do
      p = create_proposal_with_approvers(approver_user, purchaser_user)
      p.individual_steps.first.approve!
      p
    end

    before do
      login_as(purchaser_user)
      @page = MyRequestsPage.new
      @page.load
    end

    it "is correctly-named for the user role" do
      expect(@page).to have_needing_review
      expect(@page.needing_review.section_title.text).to eq "Pending Requests Needing Purchase"
    end

    it "contains requests that can be acted on by the user" do
      needing_review_section = @page.needing_review
      expect(needing_review_section.requests.first.public_id_link.text).to eq request_needing_purchase.public_id
    end

    it "does not contain requests that cannot be acted on by the user" do
      needing_review_section = @page.needing_review
      expect(needing_review_section.requests.first.public_id_link.text).to_not eq request_needing_approval.public_id
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
