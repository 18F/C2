describe Gsa18f::ProcurementPolicy do
  subject { described_class }

  permissions :can_create? do
    it "allows a user with an arbitrary email to create" do
      user = User.new(email_address: 'user@example.com', client_slug: 'gsa18f')
      procurement = Gsa18f::Procurement.new
      expect(subject).to permit(user, procurement)
    end

    with_feature 'RESTRICT_ACCESS' do
      it "allows someone with a GSA email to create" do
        gsa_domain = "@example.net"
        stub_const("GsaPolicy::GSA_DOMAIN", gsa_domain)
        user = User.new(email_address: "user#{gsa_domain}", client_slug: 'gsa18f')
        procurement = Gsa18f::Procurement.new
        expect(subject).to permit(user, procurement)
      end

      it "doesn't allow someone with a non-GSA email to create" do
        user = User.new(email_address: 'intruder@example.com', client_slug: 'gsa18f')
        procurement = Gsa18f::Procurement.new
        expect(subject).not_to permit(user, procurement)
      end
    end
  end

  permissions :can_cancel? do
    it "allows requester to cancel" do
      procurement = create(:gsa18f_procurement)
      expect(subject).to permit(procurement.proposal.requester, procurement)
    end

    it "allows approver to cancel" do
      procurement = create(:gsa18f_procurement, :with_steps)
      expect(subject).to permit(procurement.proposal.approvers.first, procurement)
    end

    it "allows approver delegate to cancel" do
      procurement = create(:gsa18f_procurement, :with_steps)
      the_delegate = create(:user, client_slug: "gsa18f")
      procurement.proposal.approvers.first.add_delegate(the_delegate)
      expect(subject).to permit(the_delegate, procurement)
    end

    it "does not allow purchaser to cancel" do
      procurement = create(:gsa18f_procurement, :with_steps)
      expect(subject).to_not permit(procurement.purchaser, procurement)
    end
  end
end
