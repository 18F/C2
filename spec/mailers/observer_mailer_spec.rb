describe ObserverMailer do
  include MailerSpecHelper

  before(:all) { ENV["DISABLE_EMAIL"] = nil }
  after(:all)  { ENV["DISABLE_EMAIL"] = "Yes" }

  describe "#observer_added_notification" do
    it "sends to the observer" do
      proposal = create(:proposal, :with_observer)
      observation = proposal.observations.first

      mail = ObserverMailer.observer_added_notification(observation, nil)

      observer = observation.user
      expect(mail.to).to eq([observer.email_address])
    end

    it "excludes who they were added by, if not available" do
      proposal = create(:proposal, :with_observer)
      observation = proposal.observations.first

      mail = ObserverMailer.observer_added_notification(observation, nil)
      expect(mail.body.encoded).to_not include("to this request by ")
    end

    it "includes the reason, if there is one" do
      proposal = create(:proposal)
      observer = create(:user)
      adder = create(:user)
      reason = "is an absolute ledge"
      proposal.add_observer(observer, adder, reason)
      observation = proposal.observations.first

      mail = ObserverMailer.observer_added_notification(observation, reason)
      expect(mail.body.encoded).to include(reason)
    end

    it "does not include reason text if there is not one" do
      proposal = create(:proposal)
      observer = create(:user)
      adder = create(:user)
      proposal.add_observer(observer, adder, nil)
      observation = proposal.observations.first

      mail = ObserverMailer.observer_added_notification(observation, nil)
      expect(mail.body.encoded).not_to include(
        I18n.t("mailer.observer_mailer.observer_added_notification.subheader",
               reason: nil)
      )
    end
  end

  describe "#observer_removed_notification" do
    it "sends to the observer" do
      proposal = create(:proposal, :with_observer)
      observation = proposal.observations.first
      observer = observation.user

      mail = ObserverMailer.observer_removed_notification(proposal, observer)

      expect(mail.to).to eq([observer.email_address])
    end
  end

  describe "#proposal_complete" do
    let(:mail) { ObserverMailer.proposal_complete(observer, proposal) }

    it_behaves_like "a proposal email"
  end

  private

  def proposal
    @proposal ||= create(:proposal)
  end

  def observer
    @observer ||= create(:observation).user
  end
end
