feature 'Approver edits NCR work order' do
  around(:each) do |example|
    with_env_var('DISABLE_SANDBOX_WARNING', 'true') do
      example.run
    end
  end

  scenario 'keeps track of the modification' do
    work_order = create(:ncr_work_order, :with_approvers)
    approver = work_order.proposal.approvers.first
    login_as(approver)

    visit "/ncr/work_orders/#{work_order.id}/edit"
    fill_in 'CL number', with: 'CL1234567'
    click_on 'Update'

    work_order.proposal.reload
    update_comments = work_order.proposal.comments.update_comments
    expect(update_comments.count).to eq(1)
    # properly attributed
    update_comment = update_comments.first
    expect(update_comment.user).to eq(approver)
    # properly tracked
    expect(update_comment.comment_text).to include("CL number")
  end
end
