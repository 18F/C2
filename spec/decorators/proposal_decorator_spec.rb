describe ProposalDecorator do
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
      proposal = create(:proposal).decorate
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

  describe "#waiting_text_for_status_in_table" do
    context "when the proposal has an actionable step" do
      it "returns the correct text" do
        proposal = create(:proposal).decorate
        approval_step = double("Steps::Approval").as_null_object
        expect(proposal).to receive(:currently_awaiting_steps).and_return([approval_step])
        expect(approval_step).to receive(:waiting_text).and_return("blah")
        expect(proposal.waiting_text_for_status_in_table).to eq "blah"
      end
    end
    context "when the proposal does not have an actionable step" do
      it "returns the correct default text" do
        proposal = build_stubbed(:proposal).decorate
        expect(proposal.waiting_text_for_status_in_table).to eq ""
      end
    end
  end

  describe "#step_text_for_user" do
    context "when the active step is an approval" do
      it "fetches approval text" do
        proposal = create(:proposal).decorate
        user = create(:user)
        step = Steps::Approval.new(user: user)
        proposal.add_initial_steps([step])

        expect(proposal.step_text_for_user(:execute_button, user)).to eq "Approve"
      end
    end

    context "when the active step is a purchase" do
      it "fetches purchase text" do
        proposal = create(:proposal).decorate
        user = create(:user)
        step = Steps::Purchase.new(user: user)
        proposal.add_initial_steps([step])

        expect(proposal.step_text_for_user(:execute_button, user)).to eq "Mark as Purchased"
      end
    end
  end
end
