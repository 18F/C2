describe Dispatcher do
  let(:proposal) { FactoryGirl.create(:proposal) }

  describe '.deliver_new_proposal_emails' do
    it "uses the LinearDispatcher for linear approvals" do
      proposal.flow = 'linear'
      expect(proposal).to receive(:client_data).and_return(double(client: 'ncr'))
      expect_any_instance_of(LinearDispatcher).to receive(:deliver_new_proposal_emails).with(proposal)
      Dispatcher.deliver_new_proposal_emails(proposal)
    end
  end

  describe '#email_approver' do
    let(:dispatcher) { Dispatcher.new }

    it 'creates a new token for the approver' do
      proposal.approvers = [FactoryGirl.create(:user)]
      approval = proposal.individual_approvals.first
      expect(CommunicartMailer).to receive_message_chain(:actions_for_approver, :deliver_later)
      expect(approval).to receive(:create_api_token!).once

      dispatcher.email_approver(approval)
    end
  end

  let(:proposal) { FactoryGirl.create(:proposal, :with_parallel_approvers) }
  let(:dispatcher) { Dispatcher.new }

  describe '#deliver_new_proposal_emails' do
    it "sends emails to the requester and all approvers" do
      dispatcher.deliver_new_proposal_emails(proposal)
      expect(email_recipients).to eq([
        proposal.approvers.first.email_address,
        proposal.approvers.second.email_address,
        proposal.requester.email_address
      ].sort)
    end

    it 'creates a new token for each approver' do
      Timecop.freeze do
        expect(dispatcher).to receive(:send_notification_email).twice
        dispatcher.deliver_new_proposal_emails(proposal)

        proposal.individual_approvals.each do |approval|
          # handle float comparison
          expect(approval.api_token.expires_at).to be_within(1.second).of(7.days.from_now)
        end
      end
    end

    it 'sends a proposal notification email to observers' do
      proposal.add_observer('observer1@some-dot-gov.gov')
      expect(CommunicartMailer).to receive_message_chain(:proposal_observer_email, :deliver_later)
      dispatcher.deliver_new_proposal_emails(proposal)
    end
  end

  describe "#deliver_cancellation_emails" do
    let (:mock_deliverer) { double('deliverer') }

    it "sends an email to each approver" do
      allow(CommunicartMailer).to receive(:cancellation_email).and_return(mock_deliverer)
      expect(proposal.approvers.count).to eq 2
      expect(mock_deliverer).to receive(:deliver_later).twice

      dispatcher.deliver_cancellation_emails(proposal)
    end

    it "sends a confirmation email to the requester" do
      allow(CommunicartMailer).to receive(:cancellation_confirmation).and_return(mock_deliverer)
      expect(mock_deliverer).to receive(:deliver_later).once

      dispatcher.deliver_cancellation_emails(proposal)
    end
  end

  describe '#on_approval_approved' do
    it "sends to the requester" do
      dispatcher.on_approval_approved(proposal.individual_approvals.first)
      expect(email_recipients).to eq([proposal.requester.email_address])
    end
  end
end
