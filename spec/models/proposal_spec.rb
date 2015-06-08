describe Proposal do
  describe '#currently_awaiting_approvers' do
    it "gives a consistently ordered list when in parallel" do
      proposal = FactoryGirl.create(:proposal, :with_approvers,
                                    flow: 'parallel')
      emails = proposal.currently_awaiting_approvers.map(&:email_address)
      expect(emails).to eq(%w(approver1@some-dot-gov.gov approver2@some-dot-gov.gov))

      proposal.approvals.first.update_attribute(:position, 5)
      emails = proposal.currently_awaiting_approvers.map(&:email_address).sort
      expect(emails).to eq(%w(approver1@some-dot-gov.gov approver2@some-dot-gov.gov))
    end

    it "gives only the first approver when linear" do
      proposal = FactoryGirl.create(:proposal, :with_approvers, flow: 'linear')
      emails = proposal.currently_awaiting_approvers.map(&:email_address)
      expect(emails).to eq(%w(approver1@some-dot-gov.gov))

      proposal.approvals.first.approve!
      emails = proposal.currently_awaiting_approvers.map(&:email_address)
      expect(emails).to eq(%w(approver2@some-dot-gov.gov))
    end
  end

  describe '#users' do
    it "returns all approvers, observers, and the requester" do
      requester = FactoryGirl.create(
        :user, email_address: 'requester@some-dot-gov.gov')
      proposal = FactoryGirl.create(
        :proposal, :with_approvers, :with_observers, requester: requester)

      emails = proposal.users.map(&:email_address).sort
      expect(emails).to eq(%w(
        approver1@some-dot-gov.gov
        approver2@some-dot-gov.gov
        observer1@some-dot-gov.gov
        observer2@some-dot-gov.gov
        requester@some-dot-gov.gov
      ))
    end

    it "returns only the rquester when it has no other users" do
      proposal = FactoryGirl.create(:proposal)
      expect(proposal.users).to eq([proposal.requester])
    end
  end
end
