describe Steps::Parallel do
  let(:proposal) { create(:proposal) }

  it "allows approvals in any order" do
    first = build(:approval_step, proposal: nil)
    second = build(:approval_step, proposal: nil)
    third = build(:approval_step, proposal: nil)
    proposal.root_step = Steps::Parallel.new(child_steps: [first, second, third])

    expect(proposal.root_step.reload.status).to eq("actionable")
    expect(first.reload.status).to eq("actionable")
    expect(second.reload.status).to eq("actionable")
    expect(third.reload.status).to eq("actionable")

    first.complete!
    expect(proposal.root_step.reload.status).to eq("actionable")
    expect(first.reload.status).to eq("completed")
    expect(second.reload.status).to eq("actionable")
    expect(third.reload.status).to eq("actionable")

    third.complete!
    expect(proposal.root_step.reload.status).to eq("actionable")
    expect(first.reload.status).to eq("completed")
    expect(second.reload.status).to eq("actionable")
    expect(third.reload.status).to eq("completed")

    second.complete!
    expect(proposal.root_step.reload.status).to eq("completed")
    expect(first.reload.status).to eq("completed")
    expect(second.reload.status).to eq("completed")
    expect(third.reload.status).to eq("completed")
  end

  it "can be used for disjunctions (ORs)" do
    first = build(:approval_step, proposal: nil)
    second = build(:approval_step, proposal: nil)
    third = build(:approval_step, proposal: nil)
    proposal.root_step = Steps::Parallel.new(min_children_needed: 2, child_steps: [first, second, third])

    first.reload.complete!
    expect(proposal.root_step.reload.status).to eq("actionable")
    expect(first.reload.status).to eq("completed")
    expect(second.reload.status).to eq("actionable")
    expect(third.reload.status).to eq("actionable")

    third.complete!
    expect(proposal.root_step.reload.status).to eq("completed")
    expect(first.reload.status).to eq("completed")
    expect(second.reload.status).to eq("actionable")
    expect(third.reload.status).to eq("completed")

    second.complete!
    expect(proposal.root_step.reload.status).to eq("completed")
    expect(first.reload.status).to eq("completed")
    expect(second.reload.status).to eq("completed")
    expect(third.reload.status).to eq("completed")
  end
end
