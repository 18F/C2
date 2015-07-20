describe Approvals::Parallel do
  let (:proposal) { FactoryGirl.create(:proposal) }

  it 'allows approvals in any order' do
    root = Approvals::Parallel.new
    first = FactoryGirl.build(:approval, parent: root, proposal: nil)
    second = FactoryGirl.build(:approval, parent: root, proposal: nil)
    third = FactoryGirl.build(:approval, parent: root, proposal: nil)
    proposal.create_or_update_approvals([root, first, second, third])

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
    first = FactoryGirl.build(:approval, parent: root, proposal: nil)
    second = FactoryGirl.build(:approval, parent: root, proposal: nil)
    third = FactoryGirl.build(:approval, parent: root, proposal: nil)
    proposal.create_or_update_approvals([root, first, second, third])

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
