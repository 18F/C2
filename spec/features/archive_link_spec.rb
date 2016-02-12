describe "archive link" do
  let(:user){ create(:user) }
  let!(:approver){ create(:user) }

  before do
    login_as(user)
  end

  it "displays archive link when more than limit" do
    stub_const("ProposalsController::CLOSED_PROPOSAL_LIMIT", 1)
    2.times.map do |i|
      wo = create(:ncr_work_order, requester: user)
      approval = create(:approval_step, proposal: wo.proposal, user: approver, status: "actionable")
      approval.approve!
    end

    visit proposals_path

    expect(page).to have_content("View the archive")
  end

  it "hides archive link when less than or equal to limit" do
    stub_const("ProposalsController::CLOSED_PROPOSAL_LIMIT", 1)
    wo = create(:ncr_work_order, requester: user)
    approval = create(:approval_step, proposal: wo.proposal, user: approver, status: "actionable")
    approval.approve!

    visit proposals_path

    expect(page).to_not have_content("View the archive")
  end
end
