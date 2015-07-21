describe Approvals::Serial do
  it 'cascades to the next approver' do
    proposal = FactoryGirl.create(:proposal)
    root = Approvals::Serial.new
    first = FactoryGirl.build(:approval, parent: root, proposal: nil)
    second = FactoryGirl.build(:approval, parent: root, proposal: nil)
    proposal.create_or_update_approvals([root, first, second])

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
