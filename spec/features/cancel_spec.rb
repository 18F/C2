describe "Cancelling a request" do
  let (:proposal) {
    FactoryGirl.create(:proposal, :with_approvers)
  }

  before do
    login_as(proposal.requester)
  end

  it "shows a cancel link for the requester" do
    visit proposal_path(proposal)
    expect(page).to have_content("Cancel my request")
  end

  it "does not show a cancel link for non-requesters" do
  end

  it "prompts the requester for a reason" do
  end

  it "successfully sends and notifies the user" do
  end


end
