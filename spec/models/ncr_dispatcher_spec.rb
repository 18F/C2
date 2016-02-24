describe NcrDispatcher do
  let!(:work_order) { create(:ncr_work_order, :with_approvers) }
  let(:proposal) { work_order.proposal }
  let(:steps) { work_order.individual_steps }
  let(:step_1) { steps.first }
  let(:step_2) { steps.second }
  let(:ncr_dispatcher) { NcrDispatcher.new }

  describe "#deliver_new_proposal_emails" do
    context "emergency work order" do
      it "sends the emergency proposal created confirmation" do
        ncr_dispatcher = NcrDispatcher.new
        work_order = create(:ncr_work_order, :is_emergency)
        proposal = work_order.proposal
        mailer_double = double(deliver_later: true)
        allow(ProposalMailer).to receive(:emergency_proposal_created_confirmation).
          with(proposal).
          and_return(mailer_double)

        ncr_dispatcher.deliver_new_proposal_emails(proposal)

        expect(ProposalMailer).to have_received(:emergency_proposal_created_confirmation).with(proposal)
      end
    end

    context "not an emergency work order" do
      it "sends the proposal created confirmation" do
        ncr_dispatcher = NcrDispatcher.new
        work_order = create(:ncr_work_order)
        proposal = work_order.proposal
        mailer_double = double(deliver_later: true)
        allow(ProposalMailer).to receive(:proposal_created_confirmation).
          with(proposal).
          and_return(mailer_double)

        ncr_dispatcher.deliver_new_proposal_emails(proposal)

        expect(ProposalMailer).to have_received(:proposal_created_confirmation).with(proposal)
      end
    end
  end

  describe '#on_approval_approved' do
    it "sends to the requester for the last approval" do
      step_1.update_attribute(:status, 'accepted')  # skip workflow
      deliveries.clear

      ncr_dispatcher.on_approval_approved(step_2)
      expect(email_recipients).to include(work_order.requester.email_address)
    end

    it "doesn't send to the requester for the not-last approval" do
      ncr_dispatcher.on_approval_approved(step_1)
      expect(email_recipients).to_not include('requester@example.com')
    end
  end

  describe '#requires_approval_notice?' do
    it 'returns true when the approval is last in the approver list' do
      expect(ncr_dispatcher.requires_approval_notice? step_2).to eq true
    end

    it 'return false when the approval is not last in the approver list' do
      expect(ncr_dispatcher.requires_approval_notice? step_1).to eq false
    end
  end

  describe '#on_proposal_update' do
    it 'notifies approvers who have already approved' do
      step_1.approve!
      deliveries.clear
      ncr_dispatcher.on_proposal_update(proposal)
      email = deliveries[0]
      expect(email.to).to eq([step_1.user.email_address])
      expect(email.html_part.body.to_s).to include("already approved")
      expect(email.html_part.body.to_s).to include("updated")
    end

    it 'current approver if they have not be notified before' do
      ncr_dispatcher.on_proposal_update(proposal)
      email = deliveries[0]
      expect(email.to).to eq([step_1.user.email_address])
      expect(email.html_part.body.to_s).not_to include("already approved")
      expect(email.html_part.body.to_s).not_to include("updated")
    end

    it 'current approver if they have be notified before' do
      create(:api_token, step: step_1)
      ncr_dispatcher.on_proposal_update(proposal)
      email = deliveries[0]
      expect(email.to).to eq([step_1.user.email_address])
      expect(email.html_part.body.to_s).not_to include("already approved")
      expect(email.html_part.body.to_s).to include("updated")
    end

    it 'does not notify observer if they are the one making the update' do
      deliveries.clear
      email = 'requester@example.com'
      user = create(:user, client_slug: "ncr", email_address: email)
      proposal.add_observer(user)
      ncr_dispatcher.on_proposal_update(proposal, proposal.observers.first)
      expect(email_recipients).to_not include(email)
    end

    it 'does not notify approver if they are the one making the update' do
      deliveries.clear
      email = step_1.user.email_address
      ncr_dispatcher.on_proposal_update(proposal, step_1.user)
      expect(email_recipients).to_not include(email)
    end

    it "does notify requester if they are not the one making the update" do
      deliveries.clear
      email = proposal.requester.email_address
      ncr_dispatcher.on_proposal_update(proposal, step_1.user)
      expect(step_1.user.email_address).to_not eq(proposal.requester.email_address)
      expect(email_recipients).to include(email)
    end
  end
end
