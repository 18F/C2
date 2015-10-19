describe ProposalPolicy::Scope do
  let(:proposal) { create(:proposal, :with_parallel_approvers, :with_observers) }

  it "allows the requester to see" do
    user = proposal.requester
    proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
    expect(proposals).to eq([proposal])
  end

  it "allows an requester to see, when there are no observers/approvers" do
    proposal = create(:proposal)
    user = proposal.requester
    proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
    expect(proposals).to eq([proposal])
  end

  it "allows an approver to see" do
    user = proposal.approvers.first
    proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
    expect(proposals).to eq([proposal])
  end

  it "does not allow a pending approver to see" do
    approval = proposal.individual_approvals.first
    user = approval.user
    approval.update_attribute(:status, 'pending')
    proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
    expect(proposals).to eq([])
  end

  it "allows a delegate to see" do
    delegate = create(:user)
    approver = proposal.approvers.first
    approver.add_delegate(delegate)

    proposals = ProposalPolicy::Scope.new(delegate, Proposal).resolve
    expect(proposals).to eq([proposal])
  end

  it "allows an observer to see" do
    user = proposal.approvers.first
    proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
    expect(proposals).to eq([proposal])
  end

  it "does not allow anyone else to see" do
    user = create(:user)
    proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
    expect(proposals).to be_empty
  end

  context "client_admin role privileges" do
    let(:requester) { create(:user) }
    let(:proposal1) { create(:proposal, :with_parallel_approvers, :with_observers, requester_id: requester.id) }
    let(:user) { create(:user, client_slug: 'abc_company', email_address: 'admin@example.com') }
    let(:proposals) { ProposalPolicy::Scope.new(user, Proposal).resolve }

    before do
      allow(Proposal).to receive(:client_slugs).and_return(%w(abc_company ncr))
    end

    it "allows them to see unassociated requests that are inside its client scope" do
      user.add_role('client_admin')
      expect(Proposal).to receive(:client_model_names).and_return(['AbcCompany::SomethingApprovable'])
      proposal.update_attributes(client_data_type: 'AbcCompany::SomethingApprovable')
      expect(proposals).to eq([proposal])
    end

    context "outside of their client scope" do
      before do
        expect(Proposal).to receive(:client_model_names).and_return(['CdfCompany::SomethingApprovable'])
      end

      it "allows them to see Proposals they are involved with" do
        user.add_role('client_admin')
        proposal.update_attributes(client_data_type: 'CdfCompany::SomethingApprovable', requester: user)
        expect(proposals).to eq([proposal])
      end

      it "prevents them from seeing outside requests" do
        proposal.update_attributes(client_data_type: 'CdfCompany::SomethingApprovable')
        expect(proposals).to be_empty
      end
    end

    it "prevents a non-admin from seeing unrelated requests" do
      expect(Proposal).to receive(:client_model_names).and_return(['AbcCompany::SomethingApprovable'])
      proposal.update_attributes(client_data_type:'AbcCompany::SomethingApprovable')
      expect(proposals).to be_empty
    end
  end

  context "admin role privileges" do
    let(:requester) { create(:user) }
    let(:proposal1) { create(:proposal, :with_parallel_approvers, :with_observers, requester_id: requester.id) }
    let(:user) { create(:user, client_slug: 'abc_company') }
    let(:proposals) { ProposalPolicy::Scope.new(user, Proposal).resolve }

    before do
      allow(Proposal).to receive(:client_slugs).and_return(%w(abc_company ncr))
    end

    it "allows an app admin to see requests inside and outside its client scope" do
      user.add_role('admin')
      proposal1.update_attributes(client_data_type:'CdfCompany::SomethingApprovable')
      proposal.update_attributes(client_data_type:'AbcCompany::SomethingApprovable')

      expect(proposals).to match_array([proposal,proposal1])
    end
  end
end
