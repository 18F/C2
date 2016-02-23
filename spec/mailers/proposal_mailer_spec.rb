describe ProposalMailer do
  include MailerSpecHelper

  describe "#proposal_created_confirmation" do
    let(:mail) { ProposalMailer.proposal_created_confirmation(proposal) }

    it_behaves_like "a proposal email"

    it "has the corect subject" do
      expect(mail.subject).to eq("Request #{proposal.public_id}: #{proposal.name}")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([proposal.requester.email_address])
    end

    it "uses the default sender name" do
      expect(sender_names(mail)).to eq(["C2"])
    end
  end

  def proposal
    @proposal ||= create(:proposal)
  end
end
