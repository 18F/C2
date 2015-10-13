describe SubscriberList do
  let(:proposal) { create(:proposal, :with_observers, :with_parallel_approvers) }
  let(:subscriber_list) { SubscriberList.new(proposal) }

  describe '#triples' do
    let(:triples) { subscriber_list.triples }

    it 'include request, observers, approvers' do
      user_ids = triples.map {|result| result[0].id}
      roles = triples.map(&:second)
      observation_ids = triples.map {|result| result[2].try(:id)}

      expect(triples.length).to be 5  # requester + 2 approver + 2 observers
      # convert to ids
      expected_users = [proposal.requester] + proposal.approvers + proposal.observers
      expect(user_ids).to eq(expected_users.map(&:id))
      expect(roles).to eq ["Requester", "Approver", "Approver", nil, nil]
      expect(observation_ids).to eq([nil, nil, nil] + proposal.observations.map(&:id).sort)
    end

    it 'sorts by name within each group' do
      proposal.observers.first.update(first_name: 'Bob', last_name: 'Bobson');
      proposal.observers.second.update(first_name: 'Ann', last_name: 'Annson');

      proposal.reload

      expect(triples[3][0].id).to be proposal.observers.second.id
      expect(triples[4][0].id).to be proposal.observers.first.id
    end

    it "removes duplicates" do
      user = proposal.approvers.first
      expect {
        proposal.add_observer(user.email_address)
      }.to_not change { triples }
    end
  end

  describe '#users' do
    it "doesn't include delegates" do
      approver = proposal.approvers.first
      delegate = create(:user)
      approver.add_delegate(delegate)

      expect(subscriber_list.users).to_not include(delegate)
    end
  end
end
