describe Approvals::Serial do
  it 'cascades to the next approver' do
    proposal = FactoryGirl.create(:proposal)
    first = FactoryGirl.build(:approval, proposal: proposal)
    second = FactoryGirl.build(:approval, proposal: proposal)
    proposal.root_approval = Approvals::Serial.new(child_approvals: [first, second])

    expect(proposal.root_approval.reload.status).to eq('actionable')
    expect(first.reload.status).to eq('actionable')
    expect(second.reload.status).to eq('pending')

    first.approve!
    expect(proposal.root_approval.reload.status).to eq('actionable')
    expect(first.reload.status).to eq('approved')
    expect(second.reload.status).to eq('actionable')

    second.approve!
    expect(proposal.root_approval.reload.status).to eq('approved')
    expect(first.reload.status).to eq('approved')
    expect(second.reload.status).to eq('approved')
  end
end
