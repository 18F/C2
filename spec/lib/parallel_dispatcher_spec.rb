describe ParallelDispatcher do
  let(:proposal) { FactoryGirl.create(:proposal, :with_cart, :with_approvers) }
  let(:dispatcher) { ParallelDispatcher.new }

  describe '#deliver_new_proposal_emails' do
    it "sends emails to the requester and all approvers" do
      dispatcher.deliver_new_proposal_emails(proposal)
      expect(email_recipients).to eq([
        'approver1@some-dot-gov.gov',
        'approver2@some-dot-gov.gov',
        proposal.requester.email_address
      ])
    end

    it 'creates a new token for each approver' do
      Timecop.freeze do
        expect(dispatcher).to receive(:send_notification_email).twice
        dispatcher.deliver_new_proposal_emails(proposal)

        proposal.approvals.each do |approval|
          # handle float comparison
          expect(approval.api_token.expires_at).to be_within(1.second).of(7.days.from_now)
        end
      end
    end

    it 'sends a proposal notification email to observers' do
      proposal.add_observer('observer1@some-dot-gov.gov')
      expect(CommunicartMailer).to receive_message_chain(:cart_observer_email, :deliver)
      dispatcher.deliver_new_proposal_emails(proposal)
    end
  end

  describe '#on_approval_approved' do
    it "sends to the requester" do
      dispatcher.on_approval_approved(proposal.approvals.first)
      expect(email_recipients).to eq([proposal.requester.email_address])
    end
  end
end
