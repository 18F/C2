feature 'Approver edits NCR work order' do
  include ProposalSpecHelper

  scenario 'keeps track of the modification', :js do
    work_order = create(:ncr_work_order, :with_approvers)
    approver = work_order.proposal.approvers.first
    login_as(approver)

    visit proposal_path(work_order.proposal)
    click_on "MODIFY"
    
    fill_in 'CL#', with: 'CL1234567'
    within(".action-bar-container") do
      click_on "SAVE"
      sleep(1)
    end
    within("#card-for-modal") do
     click_on "SAVE"
     sleep(1)
    end
  
    sleep(1)


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
