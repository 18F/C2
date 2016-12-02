describe "Canceling a request" do
  it "shows a cancel link for the requester", :js do
    proposal = create(:ncr_work_order).proposal
    login_as(proposal.requester)

    visit proposal_path(proposal)
    expect(page).to have_content("Cancel request")
  end

  it "does not show a cancel link for non-actionable user" do
    proposal = create(:proposal, :with_serial_approvers)
    login_as(proposal.approvers.last)

    visit proposal_path(proposal)

    expect(page).to_not have_content("Cancel this request")
  end

  it "shows/hide cancel form when link is selected on redesign", js: true do
    work_order = create(:ncr_work_order, :with_beta_requester)
    login_as(work_order.proposal.requester)
    visit proposal_path(work_order.proposal)
    expect(page).to have_selector(".popup-modal", visible: false)
    click_on("Cancel request")
    expect(page).to have_selector(".popup-modal", visible: true)
    click_on("NO, TAKE ME BACK")
    expect(page).to have_selector(".popup-modal", visible: false)
  end

  it "shows cancel link for admins" do
    proposal = create(:ncr_work_order).proposal
    admin_user = create(:user, :admin, client_slug: 'ncr')
    login_as(admin_user)

    visit proposal_path(proposal)

    expect(page).to have_content("Cancel request")
  end

  it "allows admin to cancel a proposal even with different client_slug", :js do
    work_order = create(:ncr_work_order)
    proposal = work_order.proposal
    admin_user = create(:user, :admin, client_slug: "gsa18f")
    login_as(admin_user)

    cancel_proposal(proposal)

    expect(page).to_not have_content("May not add observer")
  end

  it "prompts the requester for a reason", :js do
    proposal = create(:ncr_work_order).proposal
    login_as(proposal.requester)

    visit proposal_path(proposal)
    click_on("Cancel request")
    expect(page).to have_selector('.cancel-modal-content', visible: true)
  end

  context "step completers" do
    it "allows actionable step completer to cancel", :js do
      proposal = create(:ncr_work_order, :with_approvers).proposal
      login_as(proposal.approvers[0])

      cancel_proposal(proposal)

      expect(current_path).to eq(proposals_path)
    end

    it "allows actionable step delegate to cancel", :js do
      delegate = create(:user, client_slug: "ncr")
      proposal = create(:ncr_work_order, :with_approvers).proposal
      proposal.approvers[0].add_delegate(delegate)
      login_as(delegate)

      cancel_proposal(proposal)

      expect(current_path).to eq(proposals_path)
    end

    it "disallows non-actionable step completer to cancel" do
      proposal = create(:ncr_work_order, :with_approvers).proposal
      login_as(proposal.approvers.last)

      visit proposal_path(proposal)

      expect(page).to_not have_content("Cancel request")
    end
  end

  context "email", :email do
    context "proposal without approver" do
      it "sends cancelation email to requester", :js do
        proposal = create(:ncr_work_order).proposal

        login_as(proposal.requester)

        expect do
          cancel_proposal(proposal)
        end.to change { deliveries.length }.from(0).to(1)
      end
    end

    context "proposal with pending status" do
      it "does not send cancelation email to approver", :js do
        proposal = create(:ncr_work_order, :with_approvers).proposal
        proposal.individual_steps.first.update(status: "pending")

        login_as(proposal.requester)

        expect do
          cancel_proposal(proposal)
        end.to change { deliveries.length }.from(0).to(1)
        expect_one_email_sent_to(proposal.requester)
      end
    end

    context "proposal with approver" do
      it "sends cancelation emails to requester and approver", :js do
        proposal = create(:ncr_work_order, :with_approvers).proposal

        login_as(proposal.requester)

        expect do
          cancel_proposal(proposal)
        end.to change { deliveries.length }.from(0).to(2)
        expect_one_email_sent_to(proposal.requester)
        expect_one_email_sent_to(proposal.individual_steps.first.user)
      end
    end

    context "proposal with observer" do
      it "sends cancelation email to observer", :js do
        proposal = create(:ncr_work_order).proposal

        login_as(proposal.requester)
        cancel_proposal(proposal)

        expect_one_email_sent_to(proposal.requester)
        expect_one_email_sent_to(proposal.observers.first)
      end
    end
  end

  context "entering in a reason cancelation" do
    it "successfully saves comments, changes the request status", :js do
      proposal = create(:ncr_work_order).proposal
      login_as(proposal.requester)

      cancel_proposal(proposal)

      expect(current_path).to eq(proposals_path)
      expect(page).to have_content("Canceled")
      expect(proposal.reload.status).to eq("canceled")
      expect(proposal.reload.comments.last.comment_text).to eq("Request canceled with comments: This is a good reason for the cancelation.")
    end

    it "disables cancel button if the reason is blank", :js do
      proposal = create(:ncr_work_order).proposal
      login_as(proposal.requester)

      visit proposal_path(proposal)
      click_on("Cancel request")
      fill_in "reason_input", with: ""
      expect(page).to have_button('YES, CANCEL', disabled: true)
    end
  end

  context "Cancel landing page" do
    it "succesfully opens the page for a requester" do
      proposal = create(:proposal)
      login_as(proposal.requester)

      visit cancel_form_proposal_path(proposal)

      expect(page).to have_content("Cancellation: #{proposal.name}")
      expect(current_path).to eq("/proposals/#{proposal.id}/cancel_form")
    end

    it "redirects for non-requesters" do
      proposal = create(:ncr_work_order, :with_approvers).proposal
      login_as(proposal.approvers.last)

      visit cancel_form_proposal_path(proposal)

      expect(page).to have_content(" Authorization error You do not have access to this page.")
      expect(current_path).to eq("/proposals/#{proposal.id}")
    end
  end

  def cancel_proposal(proposal)
    visit proposal_path(proposal)
    click_on("Cancel request")
    sleep(2)
    fill_in "reason_input", with: "This is a good reason for the cancelation."
    click_on("YES, CANCEL")
  end

  def expect_one_email_sent_to(user)
    expect(deliveries.select do |email|
      email.to.first == user.email_address
    end.length).to eq 1
  end
end
