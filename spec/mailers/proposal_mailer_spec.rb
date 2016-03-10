describe ProposalMailer do
  include MailerSpecHelper

  describe "#proposal_created_confirmation" do
    let(:mail) { ProposalMailer.proposal_created_confirmation(proposal) }

    it_behaves_like "a proposal email"

    it "has the correct subject" do
      expect(mail.subject).to eq("Request #{proposal.public_id}: #{proposal.name}")
    end

    it "renders the receiver email" do
      expect(mail.to).to eq([proposal.requester.email_address])
    end

    it "uses the default sender name" do
      expect(sender_names(mail)).to eq(["C2"])
    end
  end

  describe "#emergency_proposal_created_confirmation" do
    let(:mail) { ProposalMailer.emergency_proposal_created_confirmation(proposal) }

    it_behaves_like "a proposal email"

    it "contains information about the proposal" do
      expect(mail.body.encoded).to include(proposal.client_data.name)
    end
  end

  describe "#proposal_complete" do
    let(:mail) { ProposalMailer.proposal_complete(proposal) }

    it_behaves_like "a proposal email"
  end

  describe "#proposal_updated_no_action_required" do
    let(:proposal) { create(:proposal, :with_approver) }
    let(:user) { proposal.requester }
    let(:comment) { create(:comment, proposal: proposal) }
    let(:mail) { ProposalMailer.proposal_updated_no_action_required(user, proposal, comment) }

    it_behaves_like "a proposal email"
  end

  describe "#proposal_updated_needs_re_review" do
    let(:proposal) { create(:proposal, :with_approver) }
    let(:user) { proposal.requester }
    let(:comment) { create(:comment, proposal: proposal) }
    let(:mail) { ProposalMailer.proposal_updated_needs_re_review(user, proposal, comment) }

    it_behaves_like "a proposal email"
  end

  describe "#proposal_updated_while_step_pending" do
    let(:proposal) { create(:proposal, :with_approver) }
    let(:step) { proposal.individual_steps.first }
    let(:comment) { create(:comment, proposal: proposal) }
    let(:mail) { ProposalMailer.proposal_updated_while_step_pending(step, comment) }

    it_behaves_like "a proposal email"
  end

  private

  def proposal
    @proposal ||= create(:ncr_work_order, :is_emergency).proposal
  end
end
