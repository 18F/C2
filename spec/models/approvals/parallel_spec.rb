describe Approvals::Parallel do
  let (:proposal) { FactoryGirl.create(:proposal) }

  it 'allows approvals in any order' do
    root = Approvals::Parallel.new
    proposal.approvals << root
    first = Approvals::Individual.new(user: FactoryGirl.create(:user), parent: root)
    proposal.approvals << first
    second = Approvals::Individual.new(user: FactoryGirl.create(:user), parent: root)
    proposal.approvals << second
    third = Approvals::Individual.new(user: FactoryGirl.create(:user), parent: root)
    proposal.approvals << third

    expect(root.reload.status).to eq('pending')
    expect(first.reload.status).to eq('pending')
    expect(second.reload.status).to eq('pending')
    expect(third.reload.status).to eq('pending')

    root.make_actionable!

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

  it 'can be used for disjunctions' do
    root = Approvals::Parallel.new(min_required: 2)
    proposal.approvals << root
    first = Approvals::Individual.new(user: FactoryGirl.create(:user), parent: root)
    proposal.approvals << first
    second = Approvals::Individual.new(user: FactoryGirl.create(:user), parent: root)
    proposal.approvals << second
    third = Approvals::Individual.new(user: FactoryGirl.create(:user), parent: root)
    proposal.approvals << third
    root.make_actionable!

    first.reload.approve!
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
