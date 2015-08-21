describe ProposalDecorator do
  let(:proposal) { FactoryGirl.build(:proposal).decorate }

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
      statuses = Approval.statuses.map(&:to_s)
      statuses = statuses.dup + statuses.clone
      statuses = randomize(statuses)

      users = statuses.map do |status|
        user = FactoryGirl.create(:user)
        FactoryGirl.create(:approval, proposal: proposal, status: status, user: user)
        user
      end

      approvals = proposal.approvals_by_status
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

  describe '#subscriber_list' do
    let(:proposal) { FactoryGirl.create(:proposal, :with_observers, :with_parallel_approvers) }

    it 'include request, observers, approvers' do
      results = proposal.decorate.subscribers_list
      user_ids = results.map {|result| result[0].id}
      roles = results.map(&:second)
      observation_ids = results.map {|result| result[2].try(:id)}

      expect(results.length).to be 5  # requester + 2 approver + 2 observers
      # convert to ids
      expected_users = [proposal.requester] + proposal.approvers + proposal.observers
      expect(user_ids).to eq(expected_users.map(&:id))
      expect(roles).to eq ["Requester", "Approver", "Approver", nil, nil]
      expect(observation_ids).to eq([nil, nil, nil] + proposal.observations.map(&:id))
    end

    it 'sorts by name within each group' do
      proposal.observers.first.update(first_name: 'Bob', last_name: 'Bobson');
      proposal.observers.second.update(first_name: 'Ann', last_name: 'Annson');
      results = proposal.decorate.subscribers_list

      expect(results[3][0].id).to be proposal.observers.second.id
      expect(results[4][0].id).to be proposal.observers.first.id
    end
  end
end
