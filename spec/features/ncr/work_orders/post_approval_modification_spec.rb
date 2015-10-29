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

  it "requires re-approval for the amount being increased" do
    visit "/ncr/work_orders/#{work_order.id}/edit"
    fill_in 'Amount', with: work_order.amount + 1
    click_on 'Update'

    expect_budget_approvals_restarted
  end

  it "requires re-approval when adding a Function code" do
    visit "/ncr/work_orders/#{work_order.id}/edit"
    fill_in 'Function code', with: 'foo'
    click_on 'Update'

    expect_budget_approvals_restarted
  end

  def expect_budget_approvals_restarted
    work_order.reload
    expect(work_order.status).to eq('pending')
    approval_statuses = work_order.individual_approvals.pluck(:status)
    expect(approval_statuses).to eq(%w(
      approved
      actionable
      pending
    ))
    # TODO check who gets notified
  end
end
