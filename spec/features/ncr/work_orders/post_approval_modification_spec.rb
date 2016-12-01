feature "post-approval modification" do
  include ProposalSpecHelper

  scenario "doesn't require re-approval for the amount being decreased" do
    work_order = create(:ncr_work_order)
    work_order.setup_approvals_and_observers
    fully_complete(work_order.proposal)

    login_as(work_order.requester)
    visit "/proposals/#{work_order.proposal.id}"
    click_on "Modify"
    fill_in "Amount", with: work_order.amount - 1
    save_and_open_page
    click_on "SAVE CHANGES"
    click_on "SAVE"

    work_order.reload
    expect(work_order.status).to eq("completed")
  end

  scenario "can do end-to-end re-approval", :email do
    work_order = create(:ncr_work_order)
    work_order.setup_approvals_and_observers
    fully_complete(work_order.proposal)

    login_as(work_order.requester)
    visit "/proposals/#{work_order.proposal.id}"
    click_on "Modify"
    fill_in "Amount", with: work_order.amount + 1
    click_on "SAVE CHANGES"
    click_on "SAVE"

    expect_budget_approvals_restarted(work_order)
    expect_actionable_step_is_budget_approver(work_order)

    restart_comment = I18n.t(
      "activerecord.attributes.proposal.user_restart_comment",
      user: work_order.requester.full_name
    ).delete("`")
    expect(page).to have_content(restart_comment)

    login_as(work_order.budget_approvers.first)
    visit "/proposals/#{work_order.proposal.id}"
    click_on "Approve"

    work_order.reload
    expect(work_order.status).to eq("completed")
    expect(work_order.proposal.root_step.status).to eq("completed")
    expect(approval_statuses(work_order)).to eq(%w(
                                                  completed
                                                  completed
                                                ))
    completed_comment = I18n.t(
      "activerecord.attributes.proposal.user_completed_comment",
      user: work_order.budget_approvers.first.full_name
    ).delete("`")
    expect(page).to have_content(completed_comment)
  end

  scenario "budget approver does not trigger re-approval" do
    work_order = create(:ncr_work_order, amount: "123")
    work_order.setup_approvals_and_observers
    fully_complete(work_order.proposal)
    budget_approver_delegate = create(:user, client_slug: "ncr")
    create(:user_delegate, assigner: work_order.budget_approvers.last, assignee: budget_approver_delegate)

    login_as(budget_approver_delegate)
    visit "/proposals/#{work_order.proposal.id}"
    click_on "Modify"
    fill_in "Amount", with: work_order.amount + 1
    click_on "SAVE"
    click_on "SAVE"
    work_order.reload

    expect(page.status_code).to eq(200)
    expect(work_order.status).to eq("completed")
    expect(work_order.proposal.root_step.status).to eq("completed")
    expect(approval_statuses(work_order)).to eq(%w(
                                                  completed
                                                  completed
                                                ))
  end

  scenario "shows flash warning, only on edit page" do
    work_order = create(:ncr_work_order)
    work_order.setup_approvals_and_observers
    fully_complete(work_order.proposal)

    login_as(work_order.requester)
    visit proposal_path(work_order.proposal)
    click_on "MODIFY"
    fill_in "Amount", with: work_order.amount + 1
    click_on "SAVE"
    expect(page).to have_content("Click Save to update your request and notify 3 participants, or click Cancel to discard your changes.")
  end

  scenario "shows modal warning on new details page", :js do
    work_order = create(:ncr_work_order, :with_beta_requester)
    work_order.setup_approvals_and_observers
    proposal = work_order.proposal
    fully_complete(proposal)

    login_as(proposal.requester)
    visit proposal_path(proposal)
    click_on "Modify"
    fill_in "Amount", with: work_order.amount + 1
    find(".save-button button").trigger("click")
    expect(page).to have_content("Wait! Updating Amount will require re-approval.")
  end

  scenario "allows you to edit an approved work order on redesign", :js do
    work_order = create(:ncr_work_order, :with_beta_requester)
    work_order.setup_approvals_and_observers
    proposal = work_order.proposal
    fully_complete(proposal)

    login_as(proposal.requester)
    visit proposal_path(proposal)
    new_amount = work_order.amount + 1
    click_on "Modify"
    fill_in "Amount", with: new_amount
    find(".save-button button").trigger("click")
    wait_for_ajax
    click_on "SAVE CHANGES"
    wait_for_ajax
    expect(page).to have_content(new_amount)
  end

  def approval_statuses(work_order)
    linear_approval_statuses(work_order.proposal)
  end

  def expect_budget_approvals_restarted(work_order)
    work_order.reload

    expect(work_order.status).to eq("pending")
    expect(work_order.proposal.root_step.status).to eq("actionable")
    expect(approval_statuses(work_order)).to eq(%w(
                                                  completed
                                                  actionable
                                                ))

    approver = work_order.budget_approvers.first
    expect(approver.email_address).to eq(Ncr::Mailboxes.ba80_budget.email_address)
    reapproval_mail = deliveries.find { |mail| mail.to.include?(approver.email_address) }
    expect(reapproval_mail.html_part.body).to include("Approve")
  end

  def expect_actionable_step_is_budget_approver(work_order)
    proposal_page = ProposalPage.new
    proposal_page.load(proposal_id: work_order.proposal.id)

    expect(proposal_page).to be_displayed
    expect(proposal_page.status).to have_approvers count: 2
    approver_page_row = proposal_page.status.actionable.first
    expect(approver_page_row.name).to have_content(work_order.budget_approvers.first.email_address)
  end
end
