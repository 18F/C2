describe Approvals::Individual do
  it 'notifies approvers when it becomes actionable' do
    approval = FactoryGirl.create(:approval)
    expect(Dispatcher).to receive(:email_approver).with(approval)
    approval.proposal.kickstart_approvals()
  end

  it 'notifies approvers in parallel' do
    proposal = FactoryGirl.create(:proposal)
    root = Approvals::Parallel.new
    expect(Dispatcher).to receive(:email_approver).twice
    proposal.create_or_update_approvals([
      root,
      FactoryGirl.build(:approval, parent: root, proposal: nil),
      FactoryGirl.build(:approval, parent: root, proposal: nil)
    ])
  end

  it 'notifies approvers in sequence' do
    proposal = FactoryGirl.create(:proposal)
    root = Approvals::Serial.new
    approval1 = FactoryGirl.build(:approval, parent: root, proposal: nil)
    approval2 = FactoryGirl.build(:approval, parent: root, proposal: nil)

    expect(Dispatcher).to receive(:email_approver).with(approval1)
    proposal.create_or_update_approvals([root, approval1, approval2])
    expect(Dispatcher).to receive(:email_approver).with(approval2)
    approval1.reload.approve!
  end
end
