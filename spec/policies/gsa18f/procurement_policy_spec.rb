describe Gsa18f::ProcurementPolicy do
  subject { described_class }

  permissions :can_create? do
    with_feature 'RESTRICT_ACCESS' do
      it "doesn't allow someone with a non-GSA email to create" do
        user = User.new(email_address: 'intruder@some.com')
        procurement = Gsa18f::Procurement.new
        expect(subject).not_to permit(user, procurement)
      end
    end
  end
end
