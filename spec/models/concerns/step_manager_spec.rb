describe StepManager do
  describe "#add_initial_step" do
    it "creates a new step series with the steps" do
      proposal = create(:proposal)
      expect(proposal.steps).to be_empty
      new_step1 = create(:approval)
      new_step2 = create(:approval)
      proposal.add_initial_steps([new_step1, new_step2])

      aggregate_failures "testing steps" do
        expect(proposal.steps.first).to be_a Steps::Serial
        expect(proposal.steps.first).to be_actionable
        expect(proposal.steps.first.child_steps).to include(new_step1, new_step2)
        expect(proposal.steps.last).to eq new_step2
        expect(new_step1).to be_actionable
      end
    end
  end

  describe "#root_step=" do
    it "sets initial approvers" do
      proposal = create(:proposal)
      approvers = create_list(:user, 3)
      individuals = approvers.map{ |user| build(:approval_step, user: user) }

      proposal.root_step = build(:parallel_step, child_steps: individuals)

      expect(proposal.steps.count).to be 4
      expect(proposal.approvers).to eq approvers
    end

    it "initates parallel" do
      users = create_list(:user, 3)
      proposal = create(:proposal)
      individuals = users.map { |user| build(:approval_step, user: user) }

      proposal.root_step = build(:parallel_step, child_steps: individuals)

      expect(proposal.approvers.count).to be 3
      expect(proposal.steps.count).to be 4
      expect(proposal.individual_steps.actionable.count).to be 3
      expect(proposal.steps.actionable.count).to be 4
    end

    it "initates linear" do
      proposal = create(:proposal)
      users = create_list(:user, 3)
      individuals = users.map { |user| build(:approval_step, user: user) }

      proposal.root_step = build(:serial_step, child_steps: individuals)

      expect(proposal.approvers.count).to be 3
      expect(proposal.steps.count).to be 4
      expect(proposal.individual_steps.actionable.count).to be 1
      expect(proposal.steps.actionable.count).to be 2
    end

    it "fixes modified parallel proposal approvals" do
      users = create_list(:user, 3)
      proposal = create(:proposal)
      individual = [build(:approval_step, user: users[0])]
      proposal.root_step = build(:parallel_step, child_steps: individual)

      expect(proposal.steps.actionable.count).to be 2
      expect(proposal.individual_steps.actionable.count).to be 1

      individuals = users.map { |user| build(:approval_step, user: user) }
      proposal.root_step = build(:parallel_step, child_steps: individuals)

      expect(proposal.steps.actionable.count).to be 4
      expect(proposal.individual_steps.actionable.count).to be 3
    end

    it "fixes modified linear proposal approvals" do
      users = create_list(:user, 3)
      proposal = create(:proposal)
      individuals = [users[0], users[1]].map { |user| build(:approval_step, user: user) }
      proposal.root_step = build(:serial_step, child_steps: individuals)

      expect(proposal.steps.actionable.count).to be 2
      expect(proposal.individual_steps.actionable.count).to be 1

      individuals.first.complete!
      individuals[1] = build(:approval_step, user: users[2])
      proposal.root_step = build(:serial_step, child_steps: individuals)

      expect(proposal.steps.completed.count).to be 1
      expect(proposal.steps.actionable.count).to be 2
      expect(proposal.individual_steps.actionable.count).to be 1
      expect(proposal.individual_steps.actionable.first.user).to eq users[2]
    end

    it "does not modify a full approved parallel proposal" do
      proposal = create(:proposal, :with_parallel_approvers)

      proposal.individual_steps.first.complete!
      proposal.individual_steps.second.complete!

      expect(proposal.steps.actionable).to be_empty
    end

    it "does not modify a full approved linear proposal" do
      proposal = create(:proposal, :with_serial_approvers)

      proposal.individual_steps.first.complete!
      proposal.individual_steps.second.complete!

      expect(proposal.steps.actionable).to be_empty
    end

    it "deletes approvals" do
      proposal = create(:proposal, :with_parallel_approvers)
      approval1, approval2 = proposal.individual_steps
      proposal.root_step = build(:serial_step, child_steps: [approval2])

      expect(Step.exists?(approval1.id)).to be false
    end
  end

  describe "#reset_status" do
    it "sets status as completed if there are no approvals" do
      proposal = create(:proposal)
      expect(proposal.pending?).to be true
      proposal.reset_status
      expect(proposal.completed?).to be true
    end

    it "keeps status as canceled if the proposal has been canceled" do
      proposal = create(:proposal, :with_parallel_approvers)
      proposal.individual_steps.first.complete!
      expect(proposal.pending?).to be true
      proposal.cancel!

      proposal.reset_status
      expect(proposal.canceled?).to be true
    end

    it "reverts to pending if a step is added" do
      proposal = create(:proposal, :with_parallel_approvers)
      proposal.individual_steps.first.complete!
      proposal.individual_steps.second.complete!
      expect(proposal.reload.completed?).to be true
      individuals = proposal.root_step.child_steps + [build(:approval_step, user: create(:user))]
      proposal.root_step = build(:parallel_step, child_steps: individuals)

      proposal.reset_status
      expect(proposal.pending?).to be true
    end

    it "does not move out of the pending state unless all are completed" do
      proposal = create(:proposal, :with_parallel_approvers)
      proposal.reset_status
      expect(proposal.pending?).to be true
      proposal.individual_steps.first.complete!

      proposal.reset_status
      expect(proposal.pending?).to be true
      proposal.individual_steps.second.complete!

      proposal.reset_status
      expect(proposal.completed?).to be true
    end
  end

  describe "#root_step" do
    it "returns the step without a parent" do
      step = create(:serial_step, parent_id: nil)
      proposal = create(:proposal, steps: [step])

      expect(proposal.root_step).to eq step
    end
  end

  describe "#parallel?" do
    it "is true if the root step is a parallel step" do
      proposal = create(:proposal, steps: [create(:parallel_step)])

      expect(proposal).to be_parallel
    end

    it "is false if the root step is not a parallel step" do
      proposal = create(:proposal, steps: [create(:serial_step)])

      expect(proposal).not_to be_parallel
    end
  end

  describe "#serial?" do
    it "is true if the root step is a serial step" do
      proposal = create(:proposal, steps: [create(:serial_step)])

      expect(proposal).to be_serial
    end

    it "is false if the root step is not a serial step" do
      proposal = create(:proposal, steps: [create(:parallel_step)])

      expect(proposal).not_to be_serial
    end
  end

  describe "#currently_awaiting_step_users" do
    it "gives a consistently ordered list when in parallel" do
      proposal = create(:proposal, :with_parallel_approvers)
      approver1, approver2 = proposal.approvers
      expect(proposal.currently_awaiting_step_users).to eq([approver1, approver2])

      proposal.individual_steps.first.update_attribute(:position, 5)
      expect(proposal.currently_awaiting_step_users).to eq([approver2, approver1])
    end

    it "gives only the first approver when linear" do
      proposal = create(:proposal, :with_serial_approvers)
      approver1, approver2 = proposal.approvers
      expect(proposal.currently_awaiting_step_users).to eq([approver1])

      proposal.individual_steps.first.complete!
      expect(proposal.currently_awaiting_step_users).to eq([approver2])
    end
  end

  describe "#ineligible_approvers" do
    it "identifies ineligible approvers" do
      proposal = create(:proposal)
      expect(proposal.ineligible_approvers).to eq([proposal.requester])
    end
  end
end
