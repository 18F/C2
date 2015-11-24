describe ProposalDecorator do
  let(:proposal) { build(:proposal).decorate }

  # if there is more than one element, return an array with a different order than the original
  def randomize(array)
    if array.size > 1
      loop do
        new_array = array.shuffle
        return new_array if new_array != array
      end
    else
      array
    end
  end

  describe '#approvals_by_status' do
    it "orders by approved, actionable, pending" do
      # make two approvals for each status, in random order
      statuses = Step.statuses.map(&:to_s)
      statuses = statuses.dup + statuses.clone
      statuses = randomize(statuses)

      users = statuses.map do |status|
        user = create(:user)
        create(:approval, proposal: proposal, status: status, user: user)
        user
      end

      approvals = proposal.steps_by_status
      expect(approvals.map(&:status)).to eq(%w(
        approved
        approved
        actionable
        actionable
        pending
        pending
      ))
      approvers = approvals.map(&:user)
      expect(approvers).not_to eq(users)
      expect(approvers.sort).to eq(users.sort)
    end
  end

  describe "#step_text_for_user" do
    let(:proposal) { create(:proposal).decorate }
    let(:user)     { create(:user) }

    context "when the active step is an approval" do
      it "fetches approval text" do
        step = Steps::Approval.new(user: user)
        proposal.add_initial_steps([step])
        expect(proposal.step_text_for_user(:execute_button, user)).to eq "Approve"
      end
    end

    context "when the active step is a purchase" do
      it "fetches purchase text" do
        step = Steps::Purchase.new(user: user)
        proposal.add_initial_steps([step])
        expect(proposal.step_text_for_user(:execute_button, user)).to eq "Mark as Purchased"
      end
    end
  end
end
