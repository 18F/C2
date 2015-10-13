describe 'Canceling a request' do
  it 'shows a cancel link for the requester' do
    proposal = create(:proposal)
    login_as(proposal.requester)

    visit proposal_path(proposal)

    expect(page).to have_content('Cancel my request')
  end

  it 'does not show a cancel link for non-requesters' do
    proposal = create(:proposal, :with_approver)
    login_as(proposal.approvers.first)

    visit proposal_path(proposal)

    expect(page).to_not have_content('Cancel my request')
  end

  it 'prompts the requester for a reason' do
    proposal = create(:proposal)
    login_as(proposal.requester)

    visit proposal_path(proposal)
    click_on('Cancel my request')

    expect(current_path).to eq("/proposals/#{proposal.id}/cancel_form")
  end

  context 'email' do
    context 'proposal without approver' do
      it 'sends cancellation email to requester' do
        ActionMailer::Base.deliveries.clear
        proposal = create(:proposal)

        login_as(proposal.requester)
        cancel_proposal(proposal)

        expect(deliveries.length).to eq(1)
      end
    end

    context 'proposal with pending status' do
      it 'does not send cancellation email to approver' do
        ActionMailer::Base.deliveries.clear
        proposal = create(:proposal, :with_approver)
        proposal.individual_approvals.first.update(status: 'pending')

        login_as(proposal.requester)
        cancel_proposal(proposal)

        expect(deliveries.length).to eq(1)
      end
    end

   context 'proposal with approver cancelled with reason' do
      it 'sends cancellation emails to requester and approver' do
        ActionMailer::Base.deliveries.clear
        proposal = create(:proposal, :with_approver)

        login_as(proposal.requester)
        cancel_proposal(proposal)

        expect(deliveries.length).to eq(2)
      end
   end
  end

  context 'entering in a reason cancellation' do
    it 'successfully saves comments, changes the request status' do
      proposal = create(:proposal)
      login_as(proposal.requester)

      cancel_proposal(proposal)

      expect(current_path).to eq("/proposals/#{proposal.id}")
      expect(page).to have_content('Your request has been cancelled')
      expect(proposal.reload.status).to eq('cancelled')
      expect(proposal.reload.comments.last.comment_text).to eq('Request cancelled with comments: This is a good reason for the cancellation.')
    end

    it 'displays an error if the reason is blank' do
      proposal = create(:proposal)
      login_as(proposal.requester)

      visit proposal_path(proposal)
      click_on('Cancel my request')
      fill_in 'reason_input', with: ''
      click_on('Yes, cancel this request')

      expect(page).to have_content('A reason for cancellation is required. Please indicate why this request needs to be cancelled.')
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
      proposal = create(:proposal, :with_approver)
      login_as(proposal.approvers.first)

      visit cancel_form_proposal_path(proposal)

      expect(page).to have_content('You are not the requester')
      expect(current_path).to eq("/proposals/#{proposal.id}")
    end
  end

  def cancel_proposal(proposal)
    visit proposal_path(proposal)
    click_on('Cancel my request')
    fill_in 'reason_input', with: 'This is a good reason for the cancellation.'
    click_on('Yes, cancel this request')
  end
end
