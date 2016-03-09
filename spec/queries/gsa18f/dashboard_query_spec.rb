describe Gsa18f::DashboardQuery do
  describe "#select_all" do
    it "returns scope Gsa18F records" do
      user = create(:user)
      proposal = create(:proposal, requester: user)
      create(:gsa18f_procurement, cost_per_unit: 10, quantity: 10,  proposal: proposal)
      now = Time.current.utc

      query = Gsa18f::DashboardQuery.new(user).select_all

      expect(query.to_a).to eq([{
        "year" => now.year.to_s,
        "month" => now.month.to_s,
        "count" => "1",
        "cost" => "100.0"
       }])
    end
  end
end
