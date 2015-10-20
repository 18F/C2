describe Steps::Parallel do
  let (:proposal) { create(:proposal) }

  it 'allows approvals in any order' do
    first = build(:approval, proposal: nil)
    second = build(:approval, proposal: nil)
    third = build(:approval, proposal: nil)
    proposal.root_step = Steps::Parallel.new(child_approvals: [first, second, third])

    expect(proposal.root_step.reload.status).to eq('actionable')
    expect(first.reload.status).to eq('actionable')
    expect(second.reload.status).to eq('actionable')
    expect(third.reload.status).to eq('actionable')

    first.approve!
    expect(proposal.root_step.reload.status).to eq('actionable')
    expect(first.reload.status).to eq('approved')
    expect(second.reload.status).to eq('actionable')
    expect(third.reload.status).to eq('actionable')

    third.approve!
    expect(proposal.root_step.reload.status).to eq('actionable')
    expect(first.reload.status).to eq('approved')
    expect(second.reload.status).to eq('actionable')
    expect(third.reload.status).to eq('approved')

    second.approve!
    expect(proposal.root_step.reload.status).to eq('approved')
    expect(first.reload.status).to eq('approved')
    expect(second.reload.status).to eq('approved')
    expect(third.reload.status).to eq('approved')
  end

  it 'can be used for disjunctions (ORs)' do
    first = build(:approval, proposal: nil)
    second = build(:approval, proposal: nil)
    third = build(:approval, proposal: nil)
    proposal.root_step = Steps::Parallel.new(min_children_needed: 2, child_approvals: [first, second, third])

    first.reload.approve!
    expect(proposal.root_step.reload.status).to eq('actionable')
    expect(first.reload.status).to eq('approved')
    expect(second.reload.status).to eq('actionable')
    expect(third.reload.status).to eq('actionable')

    third.approve!
    expect(proposal.root_step.reload.status).to eq('approved')
    expect(first.reload.status).to eq('approved')
    expect(second.reload.status).to eq('actionable')
    expect(third.reload.status).to eq('approved')

    second.approve!
    expect(proposal.root_step.reload.status).to eq('approved')
    expect(first.reload.status).to eq('approved')
    expect(second.reload.status).to eq('approved')
    expect(third.reload.status).to eq('approved')
  end
end
