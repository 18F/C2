describe SubscriberList do
  describe "#triples" do
    it "include request, observers, approvers, and purchasers" do
      proposal = create(:proposal, :with_observers, :with_approval_and_purchase)

      triples = SubscriberList.new(proposal).triples
      user_ids = triples.map {|result| result[0].id}
      roles = triples.map(&:second)
      observation_ids = triples.map {|result| result[2].try(:id)}

      expected_users = [proposal.requester] + proposal.approvers + proposal.purchasers + proposal.observers
      expect(user_ids).to eq(expected_users.map(&:id))
      expect(roles).to eq ["Requester", "Approver", "Purchaser", nil, nil]
      expect(observation_ids).to eq([nil, nil, nil] + proposal.observations.map(&:id).sort)
    end

    it "sorts by name within each group" do
      proposal = create(:proposal, :with_observers, :with_parallel_approvers)
      first_observer = proposal.observers.first
      second_observer = proposal.observers.second
      first_observer.update(first_name: "Bob", last_name: "Bobson")
      second_observer.update(first_name: "Ann", last_name: "Annson")

      triples = SubscriberList.new(proposal).triples

      expect(triples[3][0].id).to be second_observer.id
      expect(triples[4][0].id).to be first_observer.id
    end

    it "removes duplicates" do
      proposal = create(:proposal, :with_observers, :with_parallel_approvers)
      user = proposal.approvers.first

      triples = SubscriberList.new(proposal).triples

      expect {
        proposal.add_observer(user.email_address)
      }.to_not change { triples }
    end
  end
end
