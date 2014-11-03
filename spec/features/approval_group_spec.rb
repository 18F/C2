require 'spec_helper'

describe "approval groups" do
  it "saves the linear flow option" do
    login_with_oauth
    visit '/approval_groups/new'

    fill_in 'Name', with: 'MyAwesomeApprovalGroup'
    page.select 'Linear', from: 'Approval flow'
    fill_in 'Requester', with: 'test-requester-1@some-dot-gov.gov'
    fill_in 'Approver 1', with: 'test-approver-1@some-dot-gov.gov'
    fill_in 'Approver 2', with: 'test-approver-2@some-dot-gov.gov'

    expect {
      click_button 'Create Approval Group'
    }.to change { ApprovalGroup.count }.by(1)

    group = ApprovalGroup.last
    expect(group.flow).to eq('linear')
  end
end
