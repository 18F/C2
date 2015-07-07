describe Approvals::Individual do
  it 'notifies approvers when it becomes actionable' do
    proposal = FactoryGirl.create(:proposal)
    approval = proposal.add_approver('someone@example.gov')
    expect(Dispatcher).to receive(:email_approver).with(approval)
    proposal.reload.root_approval.make_actionable!
  end

  it 'notifies approvers in parallel' do
    proposal = FactoryGirl.create(:proposal)
    proposal.root_approval = Approvals::Parallel.new
    proposal.add_approver('app1@example.gov')
    proposal.add_approver('app2@example.gov')
    expect(Dispatcher).to receive(:email_approver).twice
    proposal.root_approval.make_actionable!
  end

  it 'notifies approvers in sequence' do
    proposal = FactoryGirl.create(:proposal)
    proposal.root_approval = Approvals::Serial.new
    approval1 = proposal.add_approver('app1@example.gov')
    approval2 = proposal.add_approver('app2@example.gov')
    expect(Dispatcher).to receive(:email_approver).with(approval1)
    proposal.root_approval.make_actionable!
    expect(Dispatcher).to receive(:email_approver).with(approval2)
    approval1.reload.approve!
  end
end
