describe "post-approval modification" do
  include ProposalSpecHelper

  around(:each) do |example|
    with_feature('DISABLE_SANDBOX_WARNING') do
      example.run
    end
  end

  let(:work_order) { create(:ncr_work_order) }

  before do
    work_order.setup_approvals_and_observers
    fully_approve(work_order.proposal)

    login_as(work_order.requester)
  end

  it "doesn't require re-approval for the amount being decreased" do
    visit "/ncr/work_orders/#{work_order.id}/edit"
    fill_in 'Amount', with: work_order.amount - 1
    click_on 'Update'

    work_order.reload
    expect(work_order.status).to eq('approved')
  end

  it "can do end-to-end re-approval" do
    visit "/ncr/work_orders/#{work_order.id}/edit"
    fill_in 'Amount', with: work_order.amount + 1
    click_on 'Update'

    expect_budget_approvals_restarted

    login_as(work_order.budget_approvers.first)
    visit "/proposals/#{work_order.proposal.id}"
    click_on 'Approve'

    work_order.reload
    expect(work_order.status).to eq('pending')
    expect(work_order.proposal.root_step.status).to eq('actionable')
    expect(approval_statuses).to eq(%w(
      approved
      approved
      actionable
    ))

    login_as(work_order.budget_approvers.second)
    visit "/proposals/#{work_order.proposal.id}"
    click_on 'Approve'

    work_order.reload
    expect(work_order.status).to eq('approved')
    expect(work_order.proposal.root_step.status).to eq('approved')
    expect(approval_statuses).to eq(%w(
      approved
      approved
      approved
    ))
  end

  it "shows flash warning, only on edit page" do
    visit "/ncr/work_orders/#{work_order.id}/edit"
    expect(page).to have_content("You are about to modify a fully approved request")
    click_on "Discard Changes"
    expect(page).to_not have_content("You are about to modify a fully approved request")
  end

  def approval_statuses
    linear_approval_statuses(work_order.proposal)
  end

  def expect_budget_approvals_restarted
    work_order.reload

    expect(work_order.status).to eq('pending')
    expect(work_order.proposal.root_step.status).to eq('actionable')
    expect(approval_statuses).to eq(%w(
      approved
      actionable
      pending
    ))

    approver = work_order.budget_approvers.first
    reapproval_mail = deliveries.find { |mail| mail.to.include?(approver.email_address) }
    expect(reapproval_mail.html_part.body).to include('Approve')
  end
end
