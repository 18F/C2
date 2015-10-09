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
        user = User.new(email_address: 'user@gsa.gov', client_slug: 'gsa18f')
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
end
