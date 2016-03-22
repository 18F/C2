describe Gsa18f::DashboardQuery do
  describe "#select_all" do
    it "returns scope Gsa18F records" do
      user = create(:user)
      proposal = create(:proposal, requester: user)
      # canceled proposals should be excluded from the totals
      proposal2 = create(:proposal, requester: user)
      proposal2.update(status: "canceled")
      create(:gsa18f_procurement, cost_per_unit: 10, quantity: 10,  proposal: proposal)
      create(:gsa18f_procurement, cost_per_unit: 10, quantity: 10,  proposal: proposal2)
      now = Time.current.utc

      query = described_class.new(user).select_all

      expect(query.to_a).to eq([{
        "year" => now.year.to_s,
        "month" => now.month.to_s,
        "count" => "1",
        "cost" => "100.0"
       }])
    end
  end
end
