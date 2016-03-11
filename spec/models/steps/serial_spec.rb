describe Steps::Serial do
  it 'cascades to the next approver' do
    proposal = create(:proposal)
    first = build(:approval, proposal: proposal)
    second = build(:approval, proposal: proposal)
    proposal.root_step = Steps::Serial.new(child_steps: [first, second])

    expect(proposal.root_step.reload.status).to eq('actionable')
    expect(first.reload.status).to eq('actionable')
    expect(second.reload.status).to eq('pending')

    first.complete!
    expect(proposal.root_step.reload.status).to eq('actionable')
    expect(first.reload.status).to eq('completed')
    expect(second.reload.status).to eq('actionable')

    second.complete!
    expect(proposal.root_step.reload.status).to eq('completed')
    expect(first.reload.status).to eq('completed')
    expect(second.reload.status).to eq('completed')
  end
end
