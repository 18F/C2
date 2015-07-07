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

  describe "#approval_for" do
    it 'returns the approval associated with this user' do
      proposal = FactoryGirl.create(:proposal)
      approval1 = proposal.add_approver('user1@example.gov')
      approval2 = proposal.add_approver('user2@example.gov')
      approval3 = proposal.add_approver('user3@example.gov')
      expect(proposal.approval_for(approval1.user)).to eq approval1
      expect(proposal.approval_for(approval2.user)).to eq approval2
      expect(proposal.approval_for(approval3.user)).to eq approval3
    end

    it 'returns the approval associated with a delegated user' do
      proposal = FactoryGirl.create(:proposal)
      proposal.add_approver('user1@example.gov')
      approval2 = proposal.add_approver('user2@example.gov')
      proposal.add_approver('user3@example.gov')
      delegate = FactoryGirl.create(:user)
      approval2.user.add_delegate(delegate)
      expect(proposal.approval_for(delegate)).to eq approval2
    end

    it 'only looks at user approvals' do
      proposal = FactoryGirl.create(:proposal)
      proposal.root_approval = Approvals::Serial.new
      approval1 = proposal.add_approver("user1@example.com")
      approval2 = proposal.add_approver("user2@example.com")
      expect(proposal.approval_for(approval1.user)).to eq approval1
      expect(proposal.approval_for(approval2.user)).to eq approval2
    end
  end
end
