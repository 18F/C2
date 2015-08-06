describe Approvals::Parallel do
  let (:proposal) { FactoryGirl.create(:proposal) }

  it 'allows approvals in any order' do
    first = FactoryGirl.build(:approval, proposal: nil)
    second = FactoryGirl.build(:approval, proposal: nil)
    third = FactoryGirl.build(:approval, proposal: nil)
    root = Approvals::Parallel.new
    root.child_approvals = [first, second, third]

    proposal.approvals = [root] + root.child_approvals
    root.initialize!

    expect(root.reload.status).to eq('actionable')
    expect(first.reload.status).to eq('actionable')
    expect(second.reload.status).to eq('actionable')
    expect(third.reload.status).to eq('actionable')

    first.approve!
    expect(root.reload.status).to eq('actionable')
    expect(first.reload.status).to eq('approved')
    expect(second.reload.status).to eq('actionable')
    expect(third.reload.status).to eq('actionable')

    third.approve!
    expect(root.reload.status).to eq('actionable')
    expect(first.reload.status).to eq('approved')
    expect(second.reload.status).to eq('actionable')
    expect(third.reload.status).to eq('approved')

    second.approve!
    expect(root.reload.status).to eq('approved')
    expect(first.reload.status).to eq('approved')
    expect(second.reload.status).to eq('approved')
    expect(third.reload.status).to eq('approved')
  end

  it 'can be used for disjunctions (ORs)' do
    first = FactoryGirl.build(:approval, proposal: nil)
    second = FactoryGirl.build(:approval, proposal: nil)
    third = FactoryGirl.build(:approval, proposal: nil)
    root = Approvals::Parallel.new(min_children_needed: 2)
    root.child_approvals = [first, second, third]

    proposal.approvals = [root] + root.child_approvals
    root.initialize!

    first.approve!
    expect(root.reload.status).to eq('actionable')
    expect(first.reload.status).to eq('approved')
    expect(second.reload.status).to eq('actionable')
    expect(third.reload.status).to eq('actionable')

    third.approve!
    expect(root.reload.status).to eq('approved')
    expect(first.reload.status).to eq('approved')
    expect(second.reload.status).to eq('actionable')
    expect(third.reload.status).to eq('approved')

    second.approve!
    expect(root.reload.status).to eq('approved')
    expect(first.reload.status).to eq('approved')
    expect(second.reload.status).to eq('approved')
    expect(third.reload.status).to eq('approved')
  end
end
