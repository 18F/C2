describe Dispatcher do
  let(:proposal) { FactoryGirl.create(:proposal) }

  describe '.deliver_new_proposal_emails' do
    it "uses the ParallelDispatcher for parallel approvals" do
      proposal.flow = 'parallel'
      expect_any_instance_of(ParallelDispatcher).to receive(:deliver_new_proposal_emails).with(proposal)
      Dispatcher.deliver_new_proposal_emails(proposal)
    end

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
      approval = proposal.add_approver('approver1@some-dot-gov.gov')
      expect(CommunicartMailer).to receive_message_chain(:actions_for_approver, :deliver)
      expect(approval).to receive(:create_api_token!).once

      dispatcher.email_approver(approval)
    end
  end
end
