describe ObservationPolicy do
  subject { described_class }
  let(:proposal) { FactoryGirl.create(:proposal, :with_observers, :with_parallel_approvers) }
  let(:observation) { proposal.observations.first }
  let(:client_admin) { FactoryGirl.create(:user, client_slug: 'ncr', email_address: 'client.admin@example.gov') }
  let(:admin) { FactoryGirl.create(:user, email_address: 'admin@example.gov') }

  permissions :can_destroy? do
    it "allows the observer to delete" do
      expect(subject).to permit(observation.user, observation)
    end

    with_env_var('CLIENT_ADMIN_EMAILS', 'client.admin@example.gov') do
      it "allows a client admin to delete if this client" do
        FactoryGirl.create(:ncr_work_order, proposal: proposal)
        expect(subject).to permit(client_admin, observation)
      end

      it "does not allow client admin to delete if another client" do
        FactoryGirl.create(:gsa18f_procurement, proposal: proposal)
        expect(subject).not_to permit(client_admin, observation)
      end
    end

    with_env_var('ADMIN_EMAILS', 'admin@example.gov') do
      it "allows an admin to delete" do
        expect(subject).to permit(admin, observation)
      end
    end

    it "does not allow another observer to delete" do
      expect(subject).not_to permit(proposal.observers.second, observation)
    end

    it "does not allow another a random user to delete" do
      expect(subject).not_to permit(FactoryGirl.create(:user), observation)
    end
  end
end
