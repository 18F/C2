describe Approvals::Serial do
  it 'cascades to the next approver' do
    proposal = FactoryGirl.create(:proposal)
    root = Approvals::Serial.new
    proposal.approvals << root
    first = Approvals::Individual.new(user: FactoryGirl.create(:user), parent: root)
    proposal.approvals << first
    second = Approvals::Individual.new(user: FactoryGirl.create(:user), parent: root)
    proposal.approvals << second

    expect(root.reload.status).to eq('pending')
    expect(first.reload.status).to eq('pending')
    expect(second.reload.status).to eq('pending')

    root.make_actionable!

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
