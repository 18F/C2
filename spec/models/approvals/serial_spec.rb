describe Approvals::Serial do
  it 'cascades to the next approver' do
    proposal = FactoryGirl.create(:proposal)
    first = FactoryGirl.build(:approval, proposal: proposal)
    second = FactoryGirl.build(:approval, proposal: proposal)
    root = Approvals::Serial.new
    root.child_approvals = [first, second]
    proposal.set_approvals_to([root, first, second])

    expect(root.reload.status).to eq('actionable')
    expect(first.reload.status).to eq('actionable')
    expect(second.reload.status).to eq('pending')

    first.approve!
    expect(root.reload.status).to eq('actionable')
    expect(first.reload.status).to eq('approved')
    expect(second.reload.status).to eq('actionable')

    second.approve!
    expect(root.reload.status).to eq('approved')
    expect(first.reload.status).to eq('approved')
    expect(second.reload.status).to eq('approved')
  end
end
