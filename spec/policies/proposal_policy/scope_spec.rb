describe ProposalPolicy::Scope do
  let(:proposal) { FactoryGirl.create(:proposal, :with_parallel_approvers, :with_observers) }

  it "allows the requester to see" do
    user = proposal.requester
    proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
    expect(proposals).to eq([proposal])
  end

  it "allows an requester to see, when there are no observers/approvers" do
    proposal = FactoryGirl.create(:proposal)
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
    delegate = FactoryGirl.create(:user)
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
    user = FactoryGirl.create(:user)
    proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
    expect(proposals).to be_empty
  end

  context "CLIENT_ADMIN privileges" do
    before do
      #Set up a temporary class
      module AbcCompany
        class SomethingApprovable
        end
      end
    end

    let(:proposal1) { FactoryGirl.create(:proposal, :with_parallel_approvers, :with_observers, requester_id: 555) }
    let(:user) { FactoryGirl.create(:user, client_slug: 'abc_company', email_address: 'admin@some-dot-gov.gov') }
    let(:proposals) { ProposalPolicy::Scope.new(user, Proposal).resolve }

    with_env_var('CLIENT_ADMIN_EMAILS', 'admin@some-dot-gov.gov') do
      it "allows a client admin to see unassociated requests that are inside its client scope" do
        proposal.update_attributes(client_data_type:'AbcCompany::SomethingApprovable')
        expect(proposals).to match_array([proposal])
      end

      it "prevents a client admin from seeing requests outside its client scope" do
        proposal.update_attributes(client_data_type:'CdfCompany::SomethingApprovable')
        expect(proposals).to be_empty
      end
    end

    with_env_var('CLIENT_ADMIN_EMAILS', '') do
      it "prevents a non-admin from seeing unrelated requests" do
        proposal.update_attributes(client_data_type:'AbcCompany::SomethingApprovable')
        expect(proposals).to be_empty
      end
    end
  end

  context "ADMIN privileges" do
    let(:proposal1) { FactoryGirl.create(:proposal, :with_parallel_approvers, :with_observers, requester_id: 555) }
    let(:user) { FactoryGirl.create(:user, client_slug: 'abc_company', email_address: 'admin@some-dot-gov.gov') }
    let(:proposals) { ProposalPolicy::Scope.new(user, Proposal).resolve }

    with_env_var('ADMIN_EMAILS', 'admin@some-dot-gov.gov') do
      it "allows an app admin to see requests inside and outside its client scope" do
        proposal1.update_attributes(client_data_type:'CdfCompany::SomethingApprovable')
        proposal.update_attributes(client_data_type:'AbcCompany::SomethingApprovable')

        expect(proposals).to match_array([proposal,proposal1])
      end
    end
  end
end
