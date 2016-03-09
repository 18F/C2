describe Ncr::WorkOrderPolicy do
  include EnvVarSpecHelper

  subject { described_class }

  permissions :can_edit? do
    let(:work_order) { create(:ncr_work_order, :with_approvers) }
    let(:proposal) { work_order.proposal }

    it "allows the requester to edit it" do
      expect(subject).to permit(work_order.requester, work_order)
    end

    it "allows an approver to edit it" do
      expect(subject).to permit(work_order.approvers[0], work_order)
      expect(subject).to permit(work_order.approvers[1], work_order)
    end

    it "allows approval.completer to edit it" do
      approval = work_order.individual_steps.first
      delegate_user = create(:user, client_slug: "ncr")
      approval.completer = delegate_user
      approval.save!
      expect(subject).to permit(delegate_user, work_order)
    end

    it "allows an observer to edit it" do
      observer = create(:user, client_slug: "ncr")
      proposal.add_observer(observer)
      expect(subject).to permit(observer, work_order)
    end

    it "does not allow anyone else to edit it" do
      expect(subject).not_to permit(create(:user), work_order)
    end

    it "allows an completed request to be edited" do
      proposal.update_attribute(:status, "completed")  # skip state machine
      expect(subject).to permit(proposal.requester, work_order)
    end
  end

  permissions :can_create? do
    it "allows a user with an arbitrary email to create" do
      user = User.new(email_address: 'user@example.com', client_slug: "ncr")
      work_order = Ncr::WorkOrder.new
      expect(subject).to permit(user, work_order)
    end

    it "allows someone with a GSA email to create" do
      with_env_var("RESTRICT_ACCESS", "true") do
        gsa_domain = "@example.net"
        stub_const("GsaPolicy::GSA_DOMAIN", gsa_domain)
        user = User.new(email_address: "user#{gsa_domain}", client_slug: "ncr")
        work_order = Ncr::WorkOrder.new
        expect(subject).to permit(user, work_order)
      end
    end

    it "doesn't allow someone with a non-GSA email to create" do
      with_env_var("RESTRICT_ACCESS", "true") do
        user = User.new(email_address: 'intruder@example.com', client_slug: "ncr")
        work_order = Ncr::WorkOrder.new
        expect(subject).not_to permit(user, work_order)
      end
    end
  end
end
