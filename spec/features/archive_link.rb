describe "archive link" do
  let(:user){ create(:user) }
  let!(:approver){ create(:user) }

  before do
    login_as(user)
  end

  it "displays archive link when more than 10 results" do
    proposals = 20.times.map do |i|
      wo = create(:ncr_work_order, project_title: "Work Order #{i}")
      wo.proposal.update(requester: user)
      wo.proposal.individual_approvals.create!(user: approver, status: 'actionable')
      approval = wo.proposal.existing_approval_for(approver)
      approval.approve!
      wo.proposal
    end
    visit '/proposals'
    expect(page).to have_content('View the archive')
  end

  it "hides archive link when < 10 results" do
    proposals = 9.times.map do |i| 
      wo = create(:ncr_work_order, project_title: "Work Order #{i}")
      wo.proposal.update(requester: user)
      wo.proposal.individual_approvals.create!(user: approver, status: 'actionable')
      approval = wo.proposal.existing_approval_for(approver)
      approval.approve!
      wo.proposal
    end 
    visit '/proposals'
    expect(page).to_not have_content('View the archive')
  end
end
