describe ProposalPolicy do
  subject { described_class }

  permissions :can_approve_or_reject? do
    it "allows pending delegates" do
      proposal = FactoryGirl.create(:proposal, :with_approvers)

      approval = proposal.approvals.first
      delegate = FactoryGirl.create(:user)
      approver = approval.user
      approver.add_delegate(delegate)

      expect(subject).to permit(delegate, proposal)
    end

    context "parallel cart" do
      let(:proposal) {FactoryGirl.create(:proposal, :with_approvers,
                                         flow: 'parallel')}
      let(:approval) {proposal.approvals.first}

      it "allows when there's a pending approval" do
        proposal.approvers.each{ |approver|
          expect(subject).to permit(approver, proposal)
        }
      end

      it "does not allow when the user's already approved" do
        approval.update_attribute(:status, 'approved')  # skip state machine
        expect(subject).not_to permit(approval.user, proposal)
      end

      it "does not allow when the user's already rejected" do
        approval.update_attribute(:status, 'rejected')  # skip state machine
        expect(subject).not_to permit(approval.user, proposal)
      end

      it "does not allow with a non-existent approval" do
        user = FactoryGirl.create(:user)
        expect(subject).not_to permit(user, proposal)
      end
    end

    context "linear cart" do
      let(:proposal) {FactoryGirl.create(:proposal, :with_approvers,
                                         flow: 'linear')}
      let(:first_approval) { proposal.approvals.first }
      let(:second_approval) { proposal.approvals.last }

      it "allows when there's a pending approval" do
        expect(subject).to permit(first_approval.user, proposal)
      end

      it "does not allow when it's not the user's turn" do
        user = proposal.approvers.last
        expect(subject).not_to permit(user, proposal)
      end

      it "does not allow when the user's already approved" do
        first_approval.approve!
        expect(subject).not_to permit(first_approval.user, proposal)
        expect(subject).to permit(second_approval.user, proposal)
      end

      it "does not allow when the user's already rejected" do
        first_approval.reject!
        expect(subject).not_to permit(first_approval.user, proposal)
      end

      it "does not allow with a non-existent approval" do
        user = FactoryGirl.create(:user)
        expect(subject).not_to permit(user, proposal)
      end
    end
  end

  permissions :can_show? do
    let(:proposal) {FactoryGirl.create(:proposal, :with_approvers,
                                       :with_observers)}

    it "allows the requester to see it" do
      expect(subject).to permit(proposal.requester, proposal)
    end

    it "allows an approver to see it" do
      expect(subject).to permit(proposal.approvers[0], proposal)
      expect(subject).to permit(proposal.approvers[1], proposal)
    end

    it "does not allow a pending approver to see it" do
      first_approval = proposal.approvals.first
      first_approval.update_attribute(:status, 'pending')
      expect(subject).not_to permit(first_approval.user, proposal)
      expect(subject).to permit(proposal.approvers.last, proposal)
    end

    it "allows an observer to see it" do
      expect(subject).to permit(proposal.observers[0], proposal)
    end

    it "does not allow anyone else to see it" do
      expect(subject).not_to permit(FactoryGirl.create(:user), proposal)
    end
  end

  permissions :can_edit? do
    let(:proposal) { FactoryGirl.create(:proposal, :with_approvers, :with_observers) }

    it "allows the requester to edit it" do
      expect(subject).to permit(proposal.requester, proposal)
    end

    it "doesn't allow an approver to edit it" do
      expect(subject).not_to permit(proposal.approvers[0], proposal)
      expect(subject).not_to permit(proposal.approvers[1], proposal)
    end

    it "doesn't allow an observer to edit it" do
      expect(subject).not_to permit(proposal.observers[0], proposal)
    end

    it "does not allow anyone else to edit it" do
      expect(subject).not_to permit(FactoryGirl.create(:user), proposal)
    end

    it "does not allow an approved request to be edited" do
      proposal.update_attribute(:status, 'approved')  # skip state machine
      expect(subject).not_to permit(proposal.requester, proposal)
    end
  end

  context "testing scope" do
    let(:proposal) { FactoryGirl.create(:proposal, :with_approvers, :with_observers) }

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
      approval = proposal.approvals.first
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

    context "ADMIN privileges" do
      before do
        #Set up a temporary class
        module AbcCompany
          class SomethingApprovable
          end
        end
      end

      after do
        ENV['ADMIN_EMAILS'] = ""
      end

      let(:proposal1) { FactoryGirl.create(:proposal, :with_approvers, :with_observers, requester_id: 555) }

      it "allows an admin to see unassociated requests that are inside its client scope" do
        proposal.update_attributes(client_data_type:'AbcCompany::SomethingApprovable')
        user = proposal.approvers.first
        user.client_slug = "abc_company"
        ENV['ADMIN_EMAILS'] = user.email_address

        proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
        expect(proposals).to match_array([proposal])
      end

      it "prevents an admin from seeing requests outside its client scope" do
        proposal.update_attributes(client_data_type:'AbcCompany::SomethingApprovable')
        proposal1.approvals.each {|a| a.update_attributes(user_id: 556)}
        proposal1.update_attributes(client_data_type:'CdfCompany::SomethingApprovable')

        user = proposal.approvers.first
        user.client_slug = "abc_company"
        ENV['ADMIN_EMAILS'] = user.email_address

        proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
        expect(proposals).to match_array([proposal])
      end

      it "prevents a non-admin from seeing unrelated requests" do
        proposal1.approvals.each {|a| a.update_attributes(user_id: 556)}
        proposal1.update_attributes(client_data_type:'CdfCompany::SomethingApprovable')

        proposal.update_attributes(client_data_type:'AbcCompany::SomethingApprovable', requester_id: 9876)
        user = proposal.approvers.first
        user.client_slug = "abccompany"
        proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
        expect(proposals).to match_array([proposal])
      end
    end

    context "APP_ADMIN privileges" do
      let(:proposal1) { FactoryGirl.create(:proposal, :with_approvers, :with_observers, requester_id: 555) }

      after do
        ENV['APP_ADMIN_EMAILS'] = ""
      end

      it "allows an app admin to see requests inside and outside its client scope" do
        proposal1.approvals.each {|a| a.update_attributes(user_id: 556)}
        proposal1.update_attributes(client_data_type:'CdfCompany::SomethingApprovable')
        proposal.update_attributes(client_data_type:'AbcCompany::SomethingApprovable')

        user = proposal.approvers.first
        user.client_slug = "abccompany"
        ENV['APP_ADMIN_EMAILS'] = user.email_address

        proposals = ProposalPolicy::Scope.new(user, Proposal).resolve
        expect(proposals).to match_array([proposal,proposal1])
      end
    end
  end
end
