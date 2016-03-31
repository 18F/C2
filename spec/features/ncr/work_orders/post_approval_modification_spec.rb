feature "post-approval modification" do
  include ProposalSpecHelper

  scenario "doesn't require re-approval for the amount being decreased" do
    work_order = create(:ncr_work_order)
    work_order.setup_approvals_and_observers
    fully_complete(work_order.proposal)

    login_as(work_order.requester)
    visit "/ncr/work_orders/#{work_order.id}/edit"
    fill_in 'Amount', with: work_order.amount - 1
    click_on 'Update'

    work_order.reload
    expect(work_order.status).to eq("completed")
  end

  scenario "can do end-to-end re-approval" do
    work_order = create(:ncr_work_order)
    work_order.setup_approvals_and_observers
    fully_complete(work_order.proposal)

    login_as(work_order.requester)
    visit "/ncr/work_orders/#{work_order.id}/edit"
    fill_in 'Amount', with: work_order.amount + 1
    click_on 'Update'

    expect_budget_approvals_restarted(work_order, page)

    login_as(work_order.budget_approvers.first)
    visit "/proposals/#{work_order.proposal.id}"
    click_on 'Approve'

    work_order.reload
    expect(work_order.status).to eq('pending')
    expect(work_order.proposal.root_step.status).to eq('actionable')
    expect(approval_statuses(work_order)).to eq(%w(
      completed
      completed
      actionable
    ))

    login_as(work_order.budget_approvers.second)
    visit "/proposals/#{work_order.proposal.id}"
    click_on 'Approve'

    work_order.reload
    expect(work_order.status).to eq('completed')
    expect(work_order.proposal.root_step.status).to eq('completed')
    expect(approval_statuses(work_order)).to eq(%w(
      completed
      completed
      completed
    ))
  end

  scenario "shows flash warning, only on edit page" do
    work_order = create(:ncr_work_order)
    work_order.setup_approvals_and_observers
    fully_complete(work_order.proposal)

    login_as(work_order.requester)
    visit "/ncr/work_orders/#{work_order.id}/edit"
    expect(page).to have_content("You are about to modify a fully approved request")
    click_on "Discard Changes"
    expect(page).to_not have_content("You are about to modify a fully approved request")
  end

  def approval_statuses(work_order)
    linear_approval_statuses(work_order.proposal)
  end

  def expect_budget_approvals_restarted(work_order, page)
    work_order.reload

    expect(work_order.status).to eq('pending')
    expect(work_order.proposal.root_step.status).to eq('actionable')
    expect(approval_statuses(work_order)).to eq(%w(
      completed
      actionable
      pending
    ))

    approver = work_order.budget_approvers.first
    expect(approver.email_address).to eq(Ncr::Mailboxes.ba61_tier1_budget.email_address)
    reapproval_mail = deliveries.find { |mail| mail.to.include?(approver.email_address) }
    expect(reapproval_mail.html_part.body).to include('Approve')
    approver_page_row = page.find(:css, ".step-row.pending.position-1")
    expect(approver_page_row).to have_content(approver.email_address)
  end
end
