describe Gsa18f::Procurement do
  around(:each) do |example|
    with_18f_procurement_env_variables(&example)
  end

  describe '#create_cart' do
    def approver_emails(procurement)
      procurement.user_approvals.map {|a| a.user.email_address }
    end

    it "adds 18fapprover@gsa.gov as approver email" do
      procurement = FactoryGirl.create(:gsa18f_procurement, :with_approvers)
      expect(procurement).to be_valid

      expect(approver_emails(procurement)).to eq([
        'approver1@some-dot-gov.gov',
        'approver2@some-dot-gov.gov',
        Gsa18f::Procurement.approver_email
      ])
    end
  end

  describe '#total_price' do
    it 'gets price from two fields' do
      procurement = FactoryGirl.build(
        :gsa18f_procurement, cost_per_unit: 18.50, quantity: 20)
      expect(procurement.total_price).to eq(18.50*20)
    end
  end
end
