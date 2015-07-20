describe Gsa18f::Procurement do
  with_env_vars(GSA18F_APPROVER_EMAIL: 'gsa.approver@example.gov',
                GSA18F_PURCHASER_EMAIL: 'gsa.purchaser@example.gov') do
    it 'sets up initial approvers and observers' do
      procurement = FactoryGirl.create(:gsa18f_procurement)

      expect(procurement.approvers.map(&:email_address)).to eq(['gsa.approver@example.gov'])
      expect(procurement.observers.map(&:email_address)).to eq(['gsa.purchaser@example.gov'])
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
