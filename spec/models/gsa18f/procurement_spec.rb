describe Gsa18f::Procurement do
  with_env_vars(GSA18F_APPROVER_EMAIL: 'approver@example.com',
                GSA18F_PURCHASER_EMAIL: 'purchaser@example.com') do
    it 'sets up initial approvers and observers' do
      procurement = create(:gsa18f_procurement)

      expect(procurement.approvers.map(&:email_address)).to eq(['approver@example.com'])
      expect(procurement.observers.map(&:email_address)).to eq(['purchaser@example.com'])
    end

    it "identifies eligible observers" do
      procurement = create(:gsa18f_procurement)
      user = create(:user, client_slug: 'gsa18f')
      expect(procurement.proposal.eligible_observers.to_a).to include(user)
      expect(procurement.proposal.eligible_observers.to_a).to_not include(procurement.observers)
    end
  end

  describe '#total_price' do
    it 'gets price from two fields' do
      procurement = build(
        :gsa18f_procurement, cost_per_unit: 18.50, quantity: 20)
      expect(procurement.total_price).to eq(18.50*20)
    end
  end

  describe "#public_identifier" do
    it "returns proposal id prenended with pound" do
      procurement = build(:gsa18f_procurement)
      proposal = procurement.proposal

      expect(procurement.public_identifier).to eq "##{proposal.id}"
    end
  end
end
