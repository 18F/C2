describe SubscriberList do
  describe "#triples" do
    it "include request, observers, approvers" do
      proposal = create(:proposal, :with_observers, :with_two_approvers)
      subscriber_list = SubscriberList.new(proposal)
      triples = subscriber_list.triples
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

    it "sorts by name within each group" do
      proposal = create(:proposal, :with_observers, :with_two_approvers)
      subscriber_list = SubscriberList.new(proposal)
      first_observer = proposal.observers.first
      second_observer = proposal.observers.second
      first_observer.update(first_name: "Bob", last_name: "Bobson")
      second_observer.update(first_name: "Ann", last_name: "Annson")

      triples = subscriber_list.triples

      expect(triples[3][0].id).to be second_observer.id
      expect(triples[4][0].id).to be first_observer.id
    end

    it "removes duplicates" do
      proposal = create(:proposal, :with_observers, :with_two_approvers)
      subscriber_list = SubscriberList.new(proposal)
      triples = subscriber_list.triples
      user = proposal.approvers.first

      expect {
        proposal.add_observer(user.email_address)
      }.to_not change { triples }
    end
  end

  describe "#users" do
    it "doesn't include delegates" do
      proposal = create(:proposal, :with_observers, :with_two_approvers)
      subscriber_list = SubscriberList.new(proposal)
      approver = proposal.approvers.first
      delegate = create(:user)
      approver.add_delegate(delegate)

      expect(subscriber_list.users).to_not include(delegate)
    end
  end
end
