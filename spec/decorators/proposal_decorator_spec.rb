describe ProposalDecorator do
  let(:proposal) { FactoryGirl.build(:proposal).decorate }

  describe '#approvals_by_status' do
    it "orders by approved, actionable, then pending" do
      # make two approvals for each status, in random order
      statuses = Approval.statuses.map(&:to_s)
      statuses = statuses.dup + statuses.clone
      statuses.shuffle.each do |status|
        FactoryGirl.create(:approval, proposal: proposal, status: status)
      end

      expect(proposal.approvals_by_status.map(&:status)).to eq(%w(
        approved
        approved
        actionable
        actionable
        pending
        pending
      ))
    end
  end

  describe '#number_approved' do
    it "only counts user approvals" do
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers)
      expect(proposal.decorate.number_approved).to be 0
      proposal.approvals.update_all(status: 'approved')
      expect(proposal.decorate.number_approved).to be 2
    end
  end

  describe '#total_approvers' do
    it "only counts user approvals" do
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers)
      expect(proposal.decorate.total_approvers).to be 2
    end
  end
end
