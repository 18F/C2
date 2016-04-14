describe Steps::Serial do
  it 'cascades to the next approver' do
    proposal = create(:proposal)
    first = build(:approval_step, proposal: proposal)
    second = build(:approval_step, proposal: proposal)
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

  it 'returns child_steps in the correct position order' do
    first_step = create(:approval_step, position: 1)
    second_step = create(:approval_step, position: 2)
    third_step = create(:approval_step, position: 3)
    root_step = create(:serial_step, child_steps: [first_step, third_step, second_step])
    root_step.reload

    expect(root_step.child_steps).to eq([first_step, second_step, third_step])
  end
end
