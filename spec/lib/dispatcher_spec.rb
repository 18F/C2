describe Dispatcher do
  let(:proposal) { FactoryGirl.create(:proposal) }

  describe '#email_approver' do
    let(:dispatcher) { Dispatcher.new }

    it 'creates a new token for the approver' do
      approval = proposal.add_approver('approver1@some-dot-gov.gov')
      proposal.kickstart_approvals()
      expect(CommunicartMailer).to receive_message_chain(:actions_for_approver, :deliver_now)
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
        'approver1@some-dot-gov.gov',
        'approver2@some-dot-gov.gov',
        proposal.requester.email_address
      ])
    end

    it 'sends a proposal notification email to observers' do
      proposal.add_observer('observer1@some-dot-gov.gov')
      expect(CommunicartMailer).to receive_message_chain(:proposal_observer_email, :deliver_now)
      dispatcher.deliver_new_proposal_emails(proposal)
    end
  end

  describe "#deliver_cancellation_emails" do
    let (:mock_deliverer) { double('deliverer') }

    it "sends an email to each approver" do
      allow(CommunicartMailer).to receive(:cancellation_email).and_return(mock_deliverer)
      expect(proposal.approvers.count).to eq 2
      expect(mock_deliverer).to receive(:deliver_now).twice

      dispatcher.deliver_cancellation_emails(proposal)
    end

    it "sends a confirmation email to the requester" do
      allow(CommunicartMailer).to receive(:cancellation_confirmation).and_return(mock_deliverer)
      expect(mock_deliverer).to receive(:deliver_now).once

      dispatcher.deliver_cancellation_emails(proposal)
    end
  end

  describe '#on_approval_approved' do
    it "sends to the requester" do
      proposal
      deliveries.clear
      dispatcher.on_approval_approved(proposal.user_approvals.first)
      expect(email_recipients).to eq([proposal.requester.email_address])
    end
  end
end
