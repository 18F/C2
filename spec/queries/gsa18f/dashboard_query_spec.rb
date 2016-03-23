describe Gsa18f::DashboardQuery do
  describe "#select_all" do
    it "aggregates scope Gsa18F records" do
      user = create(:user)
      proposal = create(:proposal, requester: user)
      create(:gsa18f_procurement, cost_per_unit: 10, quantity: 10, proposal: proposal)
      now = Time.current.utc

      query = described_class.new(user).select_all

      expect(query.to_a).to eq([{
                                 "year" => now.year.to_s,
                                 "month" => now.month.to_s,
                                 "count" => "1",
                                 "cost" => "100.0"
                               }])
    end

    it "does not aggregate canceled Gsa18F records" do
      user = create(:user)
      canceled_proposal = create(:proposal, requester: user)
      canceled_proposal.update(status: "canceled")
      create(:gsa18f_procurement, cost_per_unit: 10, quantity: 10, proposal: canceled_proposal)

      query = described_class.new(user).select_all

      expect(query.to_a).to eq([])
    end
  end
end
