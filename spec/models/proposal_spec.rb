describe Proposal do
  describe '#currently_awaiting_approvers' do
    it "gives a consistently ordered list when in parallel" do
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers, flow: 'parallel')
      emails = proposal.currently_awaiting_approvers.map(&:email_address)
      expect(emails).to eq(%w(approver1@some-dot-gov.gov approver2@some-dot-gov.gov))

      proposal.user_approvals.first.update_attribute(:position, 5)
      emails = proposal.currently_awaiting_approvers.map(&:email_address).sort
      expect(emails).to eq(%w(approver1@some-dot-gov.gov approver2@some-dot-gov.gov))
    end

    it "gives only the first approver when linear" do
      proposal = FactoryGirl.create(:proposal, :with_serial_approvers, flow: 'linear')
      emails = proposal.currently_awaiting_approvers.map(&:email_address)
      expect(emails).to eq(%w(approver1@some-dot-gov.gov))

      proposal.user_approvals.first.approve!
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
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers, :with_observers, requester: requester)

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

  describe "default values" do
    it 'sets status to pending' do
      expect(Proposal.new.pending?).to eq true
    end
  end

  describe "scopes" do
    let!(:approved1) { FactoryGirl.create(:proposal, status: 'approved') }
    let!(:approved2) { FactoryGirl.create(:proposal, status: 'approved') }
    let!(:pending) { FactoryGirl.create(:proposal, status: 'pending') }

    it 'returns approved proposals' do
      expect(Proposal.approved).to eq [approved1, approved2]
    end

    it 'returns pending proposals' do
      expect(Proposal.pending).to eq [pending]
    end

    it 'returns closed proposals' do
      expect(Proposal.approved).to eq [approved1, approved2]
    end
  end

  describe "#existing_approval_for" do
    it 'returns the approval associated with this user' do
      proposal = FactoryGirl.create(:proposal)
      approval1, approval2, approval3 = 3.times.map { |_| FactoryGirl.create(:approval, proposal: proposal) }
      expect(proposal.existing_approval_for(approval1.user)).to eq approval1
      expect(proposal.existing_approval_for(approval2.user)).to eq approval2
      expect(proposal.existing_approval_for(approval3.user)).to eq approval3
    end

    it 'returns the approval associated with a delegated user' do
      proposal = FactoryGirl.create(:proposal)
      FactoryGirl.create(:approval, proposal: proposal)
      approval2 = FactoryGirl.create(:approval, proposal: proposal)
      FactoryGirl.create(:approval, proposal: proposal)

      delegate = FactoryGirl.create(:user)
      approval2.user.add_delegate(delegate)

      expect(proposal.existing_approval_for(delegate)).to eq approval2
    end

    it 'only looks at user approvals' do
      proposal = FactoryGirl.create(:proposal)
      root = Approvals::Serial.new
      approval1 = FactoryGirl.build(:approval, parent: root, proposal: nil)
      approval2 = FactoryGirl.build(:approval, parent: root, proposal: nil)

      proposal.create_or_update_approvals([root, approval1, approval2])

      expect(proposal.existing_approval_for(approval1.user)).to eq approval1
      expect(proposal.existing_approval_for(approval2.user)).to eq approval2
    end
  end

  describe '#create_or_update_approvals' do
    it 'sets initial approvers' do
      proposal = FactoryGirl.create(:proposal)
      root = Approvals::Parallel.new
      user_approvals = 3.times.map { |_| FactoryGirl.build(:approval, parent: root, proposal: nil) }

      proposal.create_or_update_approvals([root] + user_approvals)

      expect(proposal.approvals.count).to be 4
      expect(proposal.approvers).to eq(user_approvals.map(&:user))
    end

    it 'does not modify existing approvers if correct' do
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers)
      old_approval1 = proposal.user_approvals.first
      old_approval2 = proposal.user_approvals.second
      root = Approvals::Parallel.new
      user_approvals = [
        FactoryGirl.build(:approval, parent: root, proposal: nil),
        FactoryGirl.build(:approval, parent: root, proposal: nil),
        FactoryGirl.build(:approval, parent: root, proposal: nil, user: old_approval2.user)
      ]

      proposal.create_or_update_approvals([root] + user_approvals)

      expect(proposal.approvals.count).to be 4
      expect(proposal.approvers).to eq(user_approvals.map(&:user))
      approval_ids = proposal.approvals.map(&:id)
      expect(approval_ids).not_to include(old_approval1.id)
      expect(approval_ids).to include(old_approval2.id)
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
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers)
      proposal.user_approvals.first.approve!
      expect(proposal.pending?).to be true
      proposal.cancel!

      proposal.reset_status()
      expect(proposal.cancelled?).to be true
    end

    it 'reverts to pending if an approval is added' do
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers)
      proposal.user_approvals.first.approve!
      proposal.user_approvals.second.approve!
      expect(proposal.reload.approved?).to be true
      FactoryGirl.create(:approval, proposal: proposal)

      proposal.reload.reset_status()
      expect(proposal.pending?).to be true
    end

    it 'does not move out of the pending state unless all are approved' do
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers)
      proposal.reset_status()
      expect(proposal.pending?).to be true
      proposal.user_approvals.first.approve!

      proposal.reset_status()
      expect(proposal.pending?).to be true
      proposal.user_approvals.second.approve!

      proposal.reset_status()
      expect(proposal.approved?).to be true
    end
  end

  describe '#approve!' do
    it "is a no-op for a cancelled request" do
      proposal = FactoryGirl.create(:proposal, :with_serial_approvers, flow: 'linear', status: 'cancelled')
      expect(proposal.user_approvals.pluck(:status)).to eq(%w(actionable pending))

      proposal.approve!

      expect(proposal.user_approvals.pluck(:status)).to eq(%w(actionable pending))
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

  describe '#restart' do
    it "creates new API tokens" do
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers)
      expect(proposal.api_tokens.size).to eq(2)

      proposal.restart!

      expect(proposal.api_tokens.unscoped.expired.size).to eq(2)
      expect(proposal.api_tokens.unexpired.size).to eq(2)
    end
  end
end
