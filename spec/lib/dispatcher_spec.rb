describe Dispatcher do
  let(:proposal) { create(:proposal) }

  describe '.deliver_new_proposal_emails' do
    it "uses the LinearDispatcher for linear approvals" do
      proposal.flow = 'linear'
      expect(proposal).to receive(:client_data).and_return(double(client_data_prefix: 'ncr'))
      expect_any_instance_of(LinearDispatcher).to receive(:deliver_new_proposal_emails).with(proposal)
      Dispatcher.deliver_new_proposal_emails(proposal)
    end
  end

  let(:proposal) { create(:proposal, :with_parallel_approvers) }
  let(:serial_proposal) { create(:proposal, :with_serial_approvers) }
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

    it 'sends a proposal notification email to observers' do
      proposal.add_observer('observer1@example.com')
      expect(CommunicartMailer).to receive_message_chain(:proposal_observer_email, :deliver_later)
      dispatcher.deliver_new_proposal_emails(proposal)
    end
  end

  describe '#deliver_attachment_emails' do
    it "emails everyone currently involved in the proposal" do
      proposal.add_observer("wiley-cat@example.com")
      dispatcher.deliver_attachment_emails(self.proposal)
      expect(email_recipients).to match_array(proposal.users.map(&:email_address))
    end

    it "does not email pending approvers" do
      dispatcher.deliver_attachment_emails(serial_proposal)
      expect(email_recipients).to_not include(serial_proposal.approvers.last.email_address)
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

    it "sends an email to each actionable approver" do
      allow(CommunicartMailer).to receive(:cancellation_email).and_return(mock_deliverer)
      expect(serial_proposal.approvers.count).to eq 2
      expect(mock_deliverer).to receive(:deliver_later).once

      dispatcher.deliver_cancellation_emails(serial_proposal)
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
