describe Gsa18f::ProcurementPolicy do
  permissions :can_create? do
    it "allows a user with an arbitrary email to create" do
      user = User.new(email_address: 'user@example.com', client_slug: 'gsa18f')
      procurement = Gsa18f::Procurement.new
      expect(Gsa18f::ProcurementPolicy).to permit(user, procurement)
    end

    with_feature 'RESTRICT_ACCESS' do
      it "allows someone with a GSA email to create" do
        gsa_domain = "@example.net"
        stub_const("GsaPolicy::GSA_DOMAIN", gsa_domain)
        user = User.new(email_address: "user#{gsa_domain}", client_slug: 'gsa18f')
        procurement = Gsa18f::Procurement.new
        expect(Gsa18f::ProcurementPolicy).to permit(user, procurement)
      end

      it "doesn't allow someone with a non-GSA email to create" do
        user = User.new(email_address: 'intruder@example.com', client_slug: 'gsa18f')
        procurement = Gsa18f::Procurement.new
        expect(Gsa18f::ProcurementPolicy).not_to permit(user, procurement)
      end
    end
  end

  permissions :can_cancel? do
    it "allows requester to cancel" do
      procurement = create(:gsa18f_procurement)
      expect(Gsa18f::ProcurementPolicy).to permit(procurement.proposal.requester, procurement)
    end

    it "allows admins to cancel" do
      procurement = create(:gsa18f_procurement)
      admin = create(:user)
      admin.add_role("admin")
      expect(Gsa18f::ProcurementPolicy).to permit(admin, procurement)
    end

    it "allows approver to cancel" do
      procurement = create(:gsa18f_procurement, :with_steps)
      expect(Gsa18f::ProcurementPolicy).to permit(procurement.proposal.approvers.first, procurement)
    end

    it "allows approver delegate to cancel" do
      procurement = create(:gsa18f_procurement, :with_steps)
      the_delegate = create(:user, client_slug: "gsa18f")
      procurement.proposal.approvers.first.add_delegate(the_delegate)
      expect(Gsa18f::ProcurementPolicy).to permit(the_delegate, procurement)
    end

    it "does not allow purchaser to cancel" do
      procurement = create(:gsa18f_procurement, :with_steps)
      expect(Gsa18f::ProcurementPolicy).to_not permit(procurement.purchaser, procurement)
    end
  end
end
