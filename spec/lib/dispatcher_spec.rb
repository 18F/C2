describe Dispatcher do
  let(:proposal) { FactoryGirl.create(:proposal) }

  describe '#email_approver' do
    let(:dispatcher) { Dispatcher.new }

    it 'creates a new token for the approver' do
      approval = proposal.add_approver('approver1@some-dot-gov.gov')
      approval.make_actionable!
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

  describe '#on_approval_approved' do
    it "sends to the requester" do
      proposal
      deliveries.clear
      dispatcher.on_approval_approved(proposal.user_approvals.first)
      expect(email_recipients).to eq([proposal.requester.email_address])
    end
  end
end
