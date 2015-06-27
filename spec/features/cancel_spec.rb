describe "Canceling a request" do
  let (:client_data) { FactoryGirl.create(:ncr_work_order) }
  let (:proposal) { FactoryGirl.create(:proposal, :with_approver, client_data_type: "Ncr::WorkOrder", client_data_id: client_data.id) }

  before do
    login_as(proposal.requester)
  end

  it "shows a cancel link for the requester" do
    visit proposal_path(proposal)
    expect(page).to have_content("Cancel my request")
  end

  it "does not show a cancel link for non-requesters" do
    login_as(proposal.approvers.first)
    visit proposal_path(proposal)
    expect(page).to_not have_content("Cancel my request")
  end

  it "prompts the requester for a reason" do
    visit proposal_path(proposal)
    click_on('Cancel my request')
    expect(current_path).to eq("/proposals/#{proposal.id}/cancel_form")
  end

  context "entering in a reason cancellation" do
    it "successfully saves comments, changes the request status" do
      visit proposal_path(proposal)
      click_on('Cancel my request')
      fill_in "reason_input", with: "This is a good reason for the cancellation."
      click_on('Yes, cancel this request')
      expect(current_path).to eq("/proposals/#{proposal.id}")
      expect(page).to have_content("Your request has been cancelled")
      expect(proposal.reload.status).to eq("cancelled")
      expect(proposal.reload.comments.last.comment_text).to eq("Request cancelled with comments: This is a good reason for the cancellation.")
    end

    it "sends and notifies the user" do

    end

    it "displays an error if the reason is blank" do
      visit proposal_path(proposal)
      click_on('Cancel my request')
      fill_in "reason_input", with: ""
      click_on('Yes, cancel this request')
      expect(current_path).to eq("/proposals/#{proposal.id}/cancel_form")
      expect(page).to have_content("A reason for cancellation is required. Please indicate why this request needs to be cancelled.")
    end
  end

  it "redirects if trying to see the cancellation page on proposals you have not rquested" do
    login_as(proposal.approvers.first)
    visit cancel_form_proposal_path(proposal)
    expect(page).to have_content("You are not allowed to perform that action")
    expect(current_path).to eq("/proposals")
  end

end
