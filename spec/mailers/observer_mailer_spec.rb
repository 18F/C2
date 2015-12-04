describe ObserverMailer do
  include MailerSpecHelper

  describe ".on_observer_added" do
    it "sends to the observer" do
      proposal = create(:proposal, :with_observer)
      observation = proposal.observations.first

      mail = ObserverMailer.on_observer_added(observation, nil)

      observer = observation.user
      expect(mail.to).to eq([observer.email_address])
    end

    it "includes who they were added by" do
      adder = create(:user)
      PaperTrail.whodunnit = adder.id

      proposal = create(:proposal, :with_observer)
      observation = proposal.observations.first
      expect(observation.created_by).to eq(adder)

      mail = ObserverMailer.on_observer_added(observation, nil)
      expect(mail.body.encoded).to include("to this request by #{adder.full_name}")
    end

    it "excludes who they were added by, if not available" do
      proposal = create(:proposal, :with_observer)
      observation = proposal.observations.first

      mail = ObserverMailer.on_observer_added(observation, nil)
      expect(mail.body.encoded).to_not include("to this request by ")
    end

    it "includes the reason, if there is one" do
      proposal = create(:proposal)
      observer = create(:user)
      adder = create(:user)
      reason = 'is an absolute ledge'
      proposal.add_observer(observer.email_address, adder, reason)
      observation = proposal.observations.first

      mail = ObserverMailer.on_observer_added(observation, reason)
      expect(mail.body.encoded).to include("with given reason '#{reason}'")
    end
  end

  describe ".proposal_observer_email" do
    with_env_vars(
      "NOTIFICATION_FROM_EMAIL" => "reply@example.com",
      "NOTIFICATION_REPLY_TO" => "replyto@example.com"
    ) do
      let(:proposal) { create(:proposal) }
      let(:observation) { proposal.add_observer('observer1@example.com') }
      let(:observer) { observation.user }
      let(:mail) { ObserverMailer.proposal_observer_email(observer.email_address, proposal) }

      it_behaves_like "a proposal email"

      it "renders the receiver email" do
        expect(mail.to).to eq(["observer1@example.com"])
      end

      it "uses the default sender name" do
        expect(sender_names(mail)).to eq(["C2"])
      end
    end
  end
end
