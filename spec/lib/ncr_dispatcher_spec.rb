describe NcrDispatcher do
  let!(:work_order) { FactoryGirl.create(:ncr_work_order, :full) }
  let(:proposal) { work_order.proposal }
  let(:approvals) { proposal.approvals }
  let(:approval_1) { approvals.first }
  let(:approval_2) { approvals.second }
  let(:ncr_dispatcher) { NcrDispatcher.new }

  describe '#on_approval_approved' do
    it "sends to the requester for the last approval" do
      approval_1.update_attribute(:status, 'accepted')  # skip workflow
      deliveries.clear

      ncr_dispatcher.on_approval_approved(approval_2)
      expect(email_recipients).to include(proposal.requester.email_address)
    end

    it "doesn't send to the requester for the not-last approval" do
      ncr_dispatcher.on_approval_approved(approval_1)
      expect(email_recipients).to_not include('requester@some-dot-gov.gov')
    end
  end

  describe '#on_proposal_rejected' do
    it "notifies the requester" do
      approval_1.update_attribute(:status, 'rejected') # avoid workflow
      ncr_dispatcher.on_proposal_rejected(proposal)
      expect(email_recipients).to include(proposal.requester.email_address)
    end
  end

  describe '#requires_approval_notice?' do
    it 'returns true when the approval is last in the approver list' do
      expect(ncr_dispatcher.requires_approval_notice? approval_2).to eq true
    end

    it 'return false when the approval is not last in the approver list' do
      expect(ncr_dispatcher.requires_approval_notice? approval_1).to eq false
    end
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
      approval_1.create_api_token!
      ncr_dispatcher.on_proposal_update(proposal)
      email = deliveries[0]
      expect(email.to).to eq([approval_1.user.email_address])
      expect(email.html_part.body.to_s).not_to include("already approved")
      expect(email.html_part.body.to_s).to include("updated")
    end
  end
end
