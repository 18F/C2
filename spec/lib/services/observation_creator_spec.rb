describe ObservationCreator do
  describe "#run" do
    it "creates a new observation for the user id and proposal id passed in" do
      proposal = create(:proposal)
      user = create(:user)

      expect {
        ObservationCreator.new(
          observer: user,
          proposal_id: proposal.id
        ).run
      }.to change { proposal.observations.count }.from(0).to(1)
    end

    context "with an adder but no reason" do
      it "sends an observer added email" do
        proposal = create(:proposal)
        observer = create(:user)
        adder = create(:user)

        expect {
          ObservationCreator.new(
            observer: observer,
            proposal_id: proposal.id,
            observer_adder: adder
          ).run
        }.to change { deliveries.length }.from(0).to(1)

      end

      it "does not add a comment" do
        proposal = create(:proposal)
        observer = create(:user)
        adder = create(:user)
        reason = " "

        ObservationCreator.new(
          observer: observer,
          proposal_id: proposal.id,
          observer_adder: adder,
          reason: reason
        ).run

        expect(proposal.comments).to be_empty
      end
    end

    context "with a reason and an adder" do
      it "adds an update comment mentioning the reason" do
        proposal = create(:proposal)
        observer = create(:user)
        adder = create(:user)
        reason = "my mate, innit"

        ObservationCreator.new(
          observer: observer,
          proposal_id: proposal.id,
          reason: reason,
          observer_adder: adder
        ).run

        expect(proposal.comments.length).to eq 1
        expect(proposal.comments.first).to be_update_comment
        expect(proposal.comments.first.comment_text).to include reason
      end

      it "sends a comment email" do
        proposal = create(:proposal)
        observer = create(:user)
        adder = create(:user)
        reason = "my mate, innit"

        expect {
          ObservationCreator.new(
            observer: observer,
            proposal_id: proposal.id,
            reason: reason,
            observer_adder: adder
          ).run
        }.to change { deliveries.length }.from(0).to(1)
      end
    end

    context "with an adder and no reason" do
      it "does not add a comment" do
        proposal = create(:proposal)
        observer = create(:user)
        adder = create(:user)

        ObservationCreator.new(
          observer: observer,
          proposal_id: proposal.id,
          observer_adder: adder
        ).run

        expect(proposal.comments).to be_empty
      end
    end
  end
end
