describe 'Canceling a request' do
  it 'shows a cancel link for the requester' do
    proposal = create(:proposal)
    login_as(proposal.requester)

    visit proposal_path(proposal)

    expect(page).to have_content('Cancel this request')
  end

  it "does not show a cancel link for non-actionable user" do
    proposal = create(:proposal, :with_serial_approvers)
    login_as(proposal.approvers.last)

    visit proposal_path(proposal)

    expect(page).to_not have_content('Cancel this request')
  end

  it "shows/hide cancel form when link is selected on redesign", js: true do
    proposal = create(:proposal)
    login_as(proposal.requester)
    visit "/proposals/#{proposal.id}?detail=new"
    expect(page).to have_selector(".cancel-modal", visible: false)
    click_on('Cancel this request')
    expect(page).to have_selector(".cancel-modal", visible: true)
    click_on('NO, TAKE ME BACK')
    expect(page).to have_selector(".cancel-modal", visible: false)
    visit "/proposals/#{proposal.id}?detail=normal"
  end

  it "shows cancel link for admins" do
    proposal = create(:proposal, :with_approver)
    admin_user = create(:user, :admin)
    login_as(admin_user)

    visit proposal_path(proposal)

    expect(page).to have_content("Cancel this request")
  end

  it "allows admin to cancel a proposal even with different client_slug" do
    work_order = create(:ncr_work_order)
    proposal = work_order.proposal
    admin_user = create(:user, :admin, client_slug: "gsa18f")
    login_as(admin_user)

    cancel_proposal(proposal)

    expect(page).to_not have_content("May not add observer")
  end

  it 'prompts the requester for a reason' do
    proposal = create(:proposal)
    login_as(proposal.requester)

    visit proposal_path(proposal)
    click_on('Cancel this request')

    expect(current_path).to eq("/proposals/#{proposal.id}/cancel_form")
  end

  context "step completers" do
    it "allows actionable step completer to cancel" do
      proposal = create(:proposal, :with_serial_approvers)
      login_as(proposal.approvers[0])

      cancel_proposal(proposal)

      expect(current_path).to eq(proposal_path(proposal))
    end

    it "allows actionable step delegate to cancel" do
      delegate = create(:user)
      proposal = create(:proposal, :with_serial_approvers)
      proposal.approvers[0].add_delegate(delegate)
      login_as(delegate)

      cancel_proposal(proposal)

      expect(current_path).to eq(proposal_path(proposal))
    end

    it "disallows non-actionable step completer to cancel" do
      proposal = create(:proposal, :with_serial_approvers)
      login_as(proposal.approvers.last)

      visit proposal_path(proposal)

      expect(page).to_not have_content("Cancel this request")
    end
  end

  context "email" do
    context "proposal without approver" do
      it "sends cancelation email to requester" do
        proposal = create(:proposal)

        login_as(proposal.requester)

        expect {
          cancel_proposal(proposal)
        }.to change { deliveries.length }.from(0).to(1)
      end
    end

    context "proposal with pending status" do
      it "does not send cancelation email to approver" do
        proposal = create(:proposal, :with_approver)
        proposal.individual_steps.first.update(status: 'pending')

        login_as(proposal.requester)

        expect {
          cancel_proposal(proposal)
        }.to change { deliveries.length }.from(0).to(1)
        expect_one_email_sent_to(proposal.requester)
      end
    end

   context "proposal with approver" do
     it "sends cancelation emails to requester and approver" do
        proposal = create(:proposal, :with_approver)

        login_as(proposal.requester)

        expect {
          cancel_proposal(proposal)
        }.to change { deliveries.length }.from(0).to(2)
        expect_one_email_sent_to(proposal.requester)
        expect_one_email_sent_to(proposal.individual_steps.last.user)
     end
   end

   context "proposal with observer" do
     it "sends cancelation email to observer" do
        proposal = create(:proposal, :with_observer)

        login_as(proposal.requester)
        cancel_proposal(proposal)

        expect_one_email_sent_to(proposal.requester)
        expect_one_email_sent_to(proposal.observers.first)
     end
   end
  end

  context 'entering in a reason cancelation' do
    it 'successfully saves comments, changes the request status' do
      proposal = create(:proposal)
      login_as(proposal.requester)

      cancel_proposal(proposal)

      expect(current_path).to eq("/proposals/#{proposal.id}")
      expect(page).to have_content('Your request has been canceled')
      expect(proposal.reload.status).to eq('canceled')
      expect(proposal.reload.comments.last.comment_text).to eq('Request canceled with comments: This is a good reason for the cancelation.')
    end

    it 'displays an error if the reason is blank' do
      proposal = create(:proposal)
      login_as(proposal.requester)

      visit proposal_path(proposal)
      click_on('Cancel this request')
      fill_in 'reason_input', with: ''
      click_on('Yes, cancel this request')

      expect(page).to have_content('A reason for cancelation is required. Please indicate why this request needs to be canceled.')
    end
  end

  context 'Cancel landing page' do
    it 'succesfully opens the page for a requester' do
      proposal = create(:proposal)
      login_as(proposal.requester)

      visit cancel_form_proposal_path(proposal)

      expect(page).to have_content("Cancellation: #{proposal.name}")
      expect(current_path).to eq("/proposals/#{proposal.id}/cancel_form")
    end

    it 'redirects for non-requesters' do
      proposal = create(:proposal, :with_serial_approvers)
      login_as(proposal.approvers.last)

      visit cancel_form_proposal_path(proposal)

      expect(page).to have_content('You are not the requester')
      expect(current_path).to eq("/proposals/#{proposal.id}")
    end
  end

  def cancel_proposal(proposal)
    visit proposal_path(proposal)
    click_on('Cancel this request')
    fill_in 'reason_input', with: 'This is a good reason for the cancelation.'
    click_on('Yes, cancel this request')
  end

  def expect_one_email_sent_to(user)
    expect(deliveries.select do |email|
      email.to.first == user.email_address
    end.length).to eq (1)
  end
end
