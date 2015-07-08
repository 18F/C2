describe NcrDispatcher do
  let!(:work_order) { FactoryGirl.create(:ncr_work_order, :with_approvers) }
  let(:proposal) { work_order.proposal }
  let(:approvals) { work_order.user_approvals }
  let(:approval_1) { approvals.first }
  let(:approval_2) { approvals.second }
  let(:ncr_dispatcher) { NcrDispatcher.new }

  it "sends to the requester for the last approval only" do
    email = work_order.requester.email_address
    approval_1.approve!
    expect(email_recipients).not_to include(email)
    expect(approval_2.proposal.approved?).to be false
    approval_2.approve!
    expect(email_recipients).to include(email)
    expect(approval_2.proposal.approved?).to be true
  end

  describe '#on_proposal_update' do
    it 'notifies approvers who have already approved' do
      approval_1.approve!
      deliveries.clear
      ncr_dispatcher.on_proposal_update(proposal)
      email = deliveries[0]
      expect(email.to).to eq([approval_1.user.email_address])
      expect(email.html_part.body.to_s).to include("already approved")
      expect(email.html_part.body.to_s).to include("updated")
    end

    it 'current approver if they have not be notified before' do
      ncr_dispatcher.on_proposal_update(proposal)
      email = deliveries[0]
      expect(email.to).to eq([approval_1.user.email_address])
      expect(email.html_part.body.to_s).not_to include("already approved")
      expect(email.html_part.body.to_s).not_to include("updated")
    end

    it 'current approver if they have be notified before' do
      proposal
      deliveries.clear
      ncr_dispatcher.on_proposal_update(proposal)
      email = deliveries[0]
      expect(email.to).to eq([approval_1.user.email_address])
      expect(email.html_part.body.to_s).not_to include("already approved")
      expect(email.html_part.body.to_s).to include("updated")
    end
  end

  describe 'requester notifications' do
    it 'only notifies the requester on final approval' do
      deliveries.clear
      approval_1.reload.approve!
      expect(email_recipients).not_to include(proposal.requester.email_address)
      approval_2.reload.approve!
      expect(email_recipients).to include(proposal.requester.email_address)
    end
  end
end
