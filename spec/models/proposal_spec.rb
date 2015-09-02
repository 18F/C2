describe Proposal do
  describe 'CLIENT_MODELS' do
    it "contains multiple models" do
      expect(Proposal::CLIENT_MODELS.size).to_not eq(0)
      Proposal::CLIENT_MODELS.each do |model|
        expect(model.ancestors).to include(ActiveRecord::Base)
      end
    end
  end

  describe '#currently_awaiting_approvers' do
    it "gives a consistently ordered list when in parallel" do
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers)
      approver1, approver2 = proposal.approvers
      expect(proposal.currently_awaiting_approvers).to eq([approver1, approver2])

      proposal.individual_approvals.first.update_attribute(:position, 5)
      expect(proposal.currently_awaiting_approvers).to eq([approver2, approver1])
    end

    it "gives only the first approver when linear" do
      proposal = FactoryGirl.create(:proposal, :with_serial_approvers)
      approver1, approver2 = proposal.approvers
      expect(proposal.currently_awaiting_approvers).to eq([approver1])

      proposal.individual_approvals.first.approve!
      expect(proposal.currently_awaiting_approvers).to eq([approver2])
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
      requester = FactoryGirl.create(:user)
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers, :with_observers, requester: requester)
      
      expect(proposal.users.map(&:id).sort).to eq([
        requester.id,
        proposal.approvers.first.id, proposal.approvers.second.id,
        proposal.observers.first.id, proposal.observers.second.id
      ].sort)
    end

    it "returns only the rquester when it has no other users" do
      proposal = FactoryGirl.create(:proposal)
      expect(proposal.users).to eq([proposal.requester])
    end

    it "removes duplicates" do
      requester = FactoryGirl.create(:user)
      proposal = FactoryGirl.create(:proposal, requester: requester)
      proposal.add_observer(requester.email_address)
      expect(proposal.users).to eq [requester]
    end

    it "adds observer from user object" do
      observer = FactoryGirl.create(:user)
      proposal = FactoryGirl.create(:proposal, requester: observer)
      proposal.add_observer(observer)
      expect(proposal.users).to eq [observer]      
    end
  end

  describe '#approvers=' do
    let(:approver1) { FactoryGirl.create(:user) }
    let(:approver2) { FactoryGirl.create(:user) }
    let(:approver3) { FactoryGirl.create(:user) }

    it 'sets initial approvers' do
      proposal = FactoryGirl.create(:proposal)
      approvers = 3.times.map{ FactoryGirl.create(:user) }

      proposal.approvers = approvers

      expect(proposal.approvals.count).to be 3
      expect(proposal.approvers).to eq approvers
    end

    it 'does not modify existing approvers if correct' do
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers)
      old_approval1 = proposal.individual_approvals.first
      old_approval2 = proposal.individual_approvals.second
      approvers = [FactoryGirl.create(:user), FactoryGirl.create(:user), old_approval2.user]

      proposal.approvers = approvers

      expect(proposal.approvers).to eq approvers
      approval_ids = proposal.approvals.map(&:id)
      expect(approval_ids).not_to include(old_approval1.id)
      expect(approval_ids).to include(old_approval2.id)
    end

    it 'initates parallel' do
      proposal = FactoryGirl.create(:proposal, flow: 'parallel')

      proposal.approvers = [approver1, approver2, approver3]

      expect(proposal.approvals.count).to be 3
      expect(proposal.approvals.actionable.count).to be 3
    end

    it 'initates linear' do
      proposal = FactoryGirl.create(:proposal, flow: 'linear')

      proposal.approvers = [approver1, approver2, approver3]

      expect(proposal.approvals.count).to be 3
      expect(proposal.approvals.actionable.count).to be 1
      expect(proposal.approvals.actionable.first.user).to eq approver1
    end

    it 'fixes modified parallel proposal approvals' do
      proposal = FactoryGirl.create(:proposal, flow: 'parallel')

      proposal.approvers = [approver1]

      expect(proposal.approvals.actionable.count).to be 1

      proposal.approvers = [approver1, approver2, approver3]
      expect(proposal.approvals.count).to be 3
      expect(proposal.approvals.actionable.count).to be 3
    end

    it 'fixes modified linear proposal approvals' do
      proposal = FactoryGirl.create(:proposal, flow: 'linear')
      approver1, approver2, approver3 = 3.times.map{ FactoryGirl.create(:user) }
      proposal.approvers = [approver1, approver2]

      expect(proposal.approvals.count).to be 2

      proposal.approvals.first.approve!
      proposal.approvers = [approver1, approver3]

      expect(proposal.approvals.approved.count).to be 1
      expect(proposal.approvals.actionable.count).to be 1
      expect(proposal.approvals.actionable.first.user).to eq approver3
    end

    it 'does not modify a full approved parallel proposal' do
      proposal = FactoryGirl.create(:proposal, flow: 'parallel')

      proposal.approvers = [approver1, approver2]

      proposal.approvals.first.approve!
      proposal.approvals.second.approve!

      expect(proposal.approvals.actionable).to be_empty
    end

    it 'does not modify a full approved linear proposal' do
      proposal = FactoryGirl.create(:proposal, flow: 'linear')

      proposal.approvers = [approver1, approver2]
      proposal.approvals.first.approve!
      proposal.approvals.second.reload.approve!

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
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers)
      proposal.individual_approvals.first.approve!
      expect(proposal.pending?).to be true
      proposal.cancel!

      proposal.reset_status()
      expect(proposal.cancelled?).to be true
    end

    it 'reverts to pending if an approval is added' do
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers)
      proposal.individual_approvals.first.approve!
      proposal.individual_approvals.second.approve!
      expect(proposal.reload.approved?).to be true
      proposal.approvers = proposal.approvers + [FactoryGirl.create(:user)]

      proposal.reset_status()
      expect(proposal.pending?).to be true
    end

    it 'does not move out of the pending state unless all are approved' do
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers)
      proposal.reset_status()
      expect(proposal.pending?).to be true
      proposal.individual_approvals.first.approve!

      proposal.reset_status()
      expect(proposal.pending?).to be true
      proposal.individual_approvals.second.approve!

      proposal.reset_status()
      expect(proposal.approved?).to be true
    end
  end

  describe '#partial_approve!' do
    it "marks the next Approval as actionable" do
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers)
      proposal.individual_approvals.first.update(status: 'approved')

      proposal.partial_approve!

      expect(proposal.individual_approvals.pluck(:status)).to eq(%w(approved actionable))
      expect(proposal.status).to eq('pending')
    end

    it "transitions to 'approved' when there are no remaining pending approvals" do
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers)
      proposal.individual_approvals.update_all(status: 'approved')

      proposal.partial_approve!

      expect(proposal.individual_approvals.first.status).to eq('approved')
      expect(proposal.status).to eq('approved')
    end

    it "is a no-op for a cancelled request" do
      proposal = FactoryGirl.create(:proposal, :with_serial_approvers, status: 'cancelled')
      expect(proposal.individual_approvals.pluck(:status)).to eq(%w(actionable pending))

      proposal.partial_approve!

      expect(proposal.individual_approvals.pluck(:status)).to eq(%w(actionable pending))
      expect(proposal.status).to eq('cancelled')
    end
  end

  describe 'scopes' do
    let(:statuses) { %w(pending approved cancelled) }
    let!(:proposals) { statuses.map{|status| FactoryGirl.create(:proposal, status: status) } }

    it "returns the appropriate proposals by status" do
      statuses.each do |status|
        expect(Proposal.send(status).pluck(:status)).to eq([status])
      end
    end

    describe '.closed' do
      it "returns approved and and cancelled proposals" do
        expect(Proposal.closed.pluck(:status).sort).to eq(%w(approved cancelled))
      end
    end
  end

  describe '#restart' do
    it "creates new API tokens" do
      proposal = FactoryGirl.create(:proposal, :with_parallel_approvers)
      proposal.individual_approvals.each(&:create_api_token!)
      expect(proposal.api_tokens.size).to eq(2)

      proposal.restart!

      expect(proposal.api_tokens.unscoped.expired.size).to eq(2)
      expect(proposal.api_tokens.unexpired.size).to eq(2)
    end
  end

  describe "#add_observer" do
    let(:proposal) { FactoryGirl.create(:proposal) }
    let(:observer) { FactoryGirl.create(:user) }
    let(:observer_email) { observer.email_address }
    let(:user) { FactoryGirl.create(:user) }
    context 'without a supplied reason' do
      it 'adds an observer to the proposal' do
        expect(proposal.observers).to be_empty
        proposal.add_observer(observer_email)
        expect(proposal.observers).to eq [observer]
      end
    end

    context 'with a supplied user & reason' do
      let(:reason) { "my mate, innit" }
      it 'adds an optional reason comment if supplied' do
        expect(proposal.comments).to be_empty
        proposal.add_observer(observer_email, user, reason)
        expect(proposal.comments.length).to eq 1
        expect(proposal.comments.first.comment_text).to include reason
      end
    end
  end
end
