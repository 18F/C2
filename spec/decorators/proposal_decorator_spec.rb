describe ProposalDecorator do
  let(:proposal) { FactoryGirl.build(:proposal).decorate }

  describe '#approvals_by_status' do
    it "orders by approved, rejected, then pending" do
      # make two approvals for each status, in random order
      statuses = Approval.statuses.map(&:to_s)
      statuses = statuses.dup + statuses.clone
      statuses.shuffle.each do |status|
        FactoryGirl.create(:approval, proposal: proposal, status: status)
      end

      expect(proposal.approvals_by_status.map(&:status)).to eq(%w(
        approved
        approved
        rejected
        rejected
        actionable
        actionable
        pending
        pending
      ))
    end
  end

  describe '#email_subject' do
    it "includes the public_identifier" do
      proposal.save!
      expect(proposal.email_subject).to eq("Request ##{proposal.id}")
    end
  end
end
