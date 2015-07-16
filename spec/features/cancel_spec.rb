describe "Canceling a request" do
  let (:client_data) { FactoryGirl.create(:ncr_work_order) }
  let (:proposal) { FactoryGirl.create(:proposal, :with_approver, client_data_type: "Ncr::WorkOrder", client_data_id: client_data.id) }
  let (:user) { FactoryGirl.create(:user, id: 123456) }

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

  context 'email' do
    around(:each) { ActionMailer::Base.deliveries.clear }

    it "send emails when cancellation is complete" do
        expect(deliveries.length).to eq(0)
        visit proposal_path(proposal)
        click_on('Cancel my request')
        fill_in "reason_input", with: "This is a good reason for the cancellation."
        click_on('Yes, cancel this request')
        expect(deliveries.length).to eq(2)
    end
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

    it "displays an error if the reason is blank" do
      visit proposal_path(proposal)
      click_on('Cancel my request')
      fill_in "reason_input", with: ""
      click_on('Yes, cancel this request')
      expect(page).to have_content("A reason for cancellation is required. Please indicate why this request needs to be cancelled.")
    end
  end

  context "Cancel landing page" do
    it "succesfully opens the page for a requester" do
      login_as(proposal.requester)
      visit cancel_form_proposal_path(proposal)
      expect(page).to have_content("Cancellation: #{proposal.name}")
      expect(current_path).to eq("/proposals/#{proposal.id}/cancel_form")
    end

    it "redirects for non-requesters" do
      login_as(proposal.approvers.first)
      visit cancel_form_proposal_path(proposal)
      expect(page).to have_content("You are not the requester")
      expect(current_path).to eq("/proposals/#{proposal.id}")
    end
  end

end
