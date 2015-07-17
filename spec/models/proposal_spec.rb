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

  describe '#delegate_with_default' do
    it "returns the delegated value" do
      proposal = Proposal.new
      client_data = double(some_prop: 'foo')
      expect(proposal).to receive(:client_data).and_return(client_data)

      result = proposal.delegate_with_default(:some_prop)
      expect(result).to eq('foo')
    end

    it "returns the default when the delegated value is #blank?" do
      proposal = Proposal.new
      client_data = double(some_prop: '')
      expect(proposal).to receive(:client_data).and_return(client_data)

      result = proposal.delegate_with_default(:some_prop) { 'foo' }
      expect(result).to eq('foo')
    end

    it "returns the default when there is no method on the delegate" do
      proposal = Proposal.new
      expect(proposal).to receive(:client_data).and_return(double)

      result = proposal.delegate_with_default(:some_prop) { 'foo' }
      expect(result).to eq('foo')
    end
  end

  describe '#name' do
    it "returns the #public_identifier by default" do
      proposal = Proposal.new
      expect(proposal).to receive(:id).and_return(6)

      expect(proposal.name).to eq('Request #6')
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

  describe '#approvers=' do
    it 'sets initial approvers' do
      proposal = FactoryGirl.create(:proposal)
      approvers = 3.times.map{ FactoryGirl.create(:user) }

      proposal.approvers = approvers

      expect(proposal.approvals.count).to be 3
      expect(proposal.approvers).to eq approvers
    end

    it 'does not modify existing approvers if correct' do
      proposal = FactoryGirl.create(:proposal, :with_approvers)
      old_approval1 = proposal.approvals.first
      old_approval2 = proposal.approvals.second
      approvers = [FactoryGirl.create(:user), FactoryGirl.create(:user), old_approval2.user]

      proposal.approvers = approvers

      expect(proposal.approvals.count).to be 3
      expect(proposal.approvers).to eq approvers
      approval_ids = proposal.approvals.map(&:id)
      expect(approval_ids).not_to include(old_approval1.id)
      expect(approval_ids).to include(old_approval2.id)
    end
  end

  describe '#kickstart_approvals' do
    it 'initates parallel' do
      proposal = FactoryGirl.create(:proposal, flow: 'parallel')
      proposal.add_approver('1@example.com')
      proposal.add_approver('2@example.com')
      proposal.add_approver('3@example.com')

      proposal.kickstart_approvals()

      expect(proposal.approvals.count).to be 3
      expect(proposal.approvals.actionable.count).to be 3
    end

    it 'initates linear' do
      proposal = FactoryGirl.create(:proposal, flow: 'linear')
      proposal.add_approver('1@example.com')
      proposal.add_approver('2@example.com')
      proposal.add_approver('3@example.com')

      proposal.kickstart_approvals()

      expect(proposal.approvals.count).to be 3
      expect(proposal.approvals.actionable.count).to be 1
      expect(proposal.approvals.actionable.first.user.email_address).to eq '1@example.com'
    end

    it 'fixes modified parallel proposal approvals' do
      proposal = FactoryGirl.create(:proposal, flow: 'parallel')
      proposal.add_approver('1@example.com')

      proposal.kickstart_approvals()

      expect(proposal.approvals.actionable.count).to be 1

      proposal.add_approver('2@example.com')
      proposal.add_approver('3@example.com')
      expect(proposal.approvals.count).to be 3
      expect(proposal.approvals.actionable.count).to be 1

      proposal.kickstart_approvals()

      expect(proposal.approvals.actionable.count).to be 3
    end

    it 'fixes modified linear proposal approvals' do
      proposal = FactoryGirl.create(:proposal, flow: 'linear')
      proposal.add_approver('1@example.com')
      proposal.add_approver('2@example.com')

      proposal.kickstart_approvals()

      expect(proposal.approvals.count).to be 2

      proposal.approvals.first.approve!
      proposal.remove_approver('2@example.com')
      proposal.add_approver('3@example.com')

      proposal.kickstart_approvals()

      expect(proposal.approvals.approved.count).to be 1
      expect(proposal.approvals.actionable.count).to be 1
      expect(proposal.approvals.actionable.first.user.email_address).to eq '3@example.com'
    end

    it 'does not modify a full approved parallel proposal' do
      proposal = FactoryGirl.create(:proposal, flow: 'parallel')
      proposal.add_approver('1@example.com')
      proposal.add_approver('2@example.com')

      proposal.kickstart_approvals()
      proposal.approvals.first.approve!
      proposal.approvals.second.approve!

      expect(proposal.approvals.actionable).to be_empty
    end

    it 'does not modify a full approved linear proposal' do
      proposal = FactoryGirl.create(:proposal, flow: 'linear')
      proposal.add_approver('1@example.com')
      proposal.add_approver('2@example.com')

      proposal.kickstart_approvals()
      proposal.approvals.first.approve!
      proposal.approvals.second.approve!

      expect(proposal.approvals.actionable).to be_empty
    end
  end

  describe '#reset_status' do
    it 'sets status as approved if there are no approvals' do
      proposal = FactoryGirl.create(:proposal)
      expect(proposal.pending?).to be true
      proposal.reset_status()
      expect(proposal.approved?).to be true
    end

    it 'sets status as cancelled if the proposal has been cancelled' do
      proposal = FactoryGirl.create(:proposal, :with_approvers)
      proposal.approvals.first.approve!
      expect(proposal.pending?).to be true
      proposal.cancel!

      proposal.reset_status()
      expect(proposal.cancelled?).to be true
    end

    it 'reverts to pending if an approval is added' do
      proposal = FactoryGirl.create(:proposal, :with_approvers)
      proposal.approvals.first.approve!
      proposal.approvals.second.approve!
      expect(proposal.approved?).to be true
      proposal.add_approver('new_approver@example.gov')

      proposal.reset_status()
      expect(proposal.pending?).to be true
    end

    it 'does not move out of the pending state unless all are approved' do
      proposal = FactoryGirl.create(:proposal, :with_approvers)
      proposal.reset_status()
      expect(proposal.pending?).to be true
      proposal.approvals.first.approve!

      proposal.reset_status()
      expect(proposal.pending?).to be true
      proposal.approvals.second.approve!

      proposal.reset_status()
      expect(proposal.approved?).to be true
    end
  end

  describe '#partial_approve!' do
    it "marks the next Approval as actionable" do
      proposal = FactoryGirl.create(:proposal, :with_approvers)
      proposal.approvals.first.update(status: 'approved')

      proposal.partial_approve!

      expect(proposal.approvals.pluck(:status)).to eq(%w(approved actionable))
      expect(proposal.status).to eq('pending')
    end

    it "transitions to 'approved' when there are no remaining pending approvals" do
      proposal = FactoryGirl.create(:proposal, :with_approver)
      proposal.approvals.update_all(status: 'approved')

      proposal.partial_approve!

      expect(proposal.approvals.first.status).to eq('approved')
      expect(proposal.status).to eq('approved')
    end

    it "is a no-op for a cancelled request" do
      proposal = FactoryGirl.create(:proposal, :with_approvers, flow: 'linear', status: 'cancelled')
      expect(proposal.approvals.pluck(:status)).to eq(%w(actionable pending))

      proposal.partial_approve!

      expect(proposal.approvals.pluck(:status)).to eq(%w(actionable pending))
      expect(proposal.status).to eq('cancelled')
    end
  end

  describe "scopes" do
    let(:statuses) { %w(pending approved cancelled) }
    let!(:proposals) { statuses.map{|status| FactoryGirl.create(:proposal, status: status) } }

    it "returns the appropriate proposals by status" do
      statuses.each do |status|
        expect(Proposal.send(status).pluck(:status)).to eq([status])
      end
    end

    describe '#closed' do
      it "returns approved and and cancelled proposals" do
        expect(Proposal.closed.pluck(:status).sort).to eq(%w(approved cancelled))
      end
    end
  end
end
