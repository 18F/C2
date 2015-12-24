describe NcrDashboardQuery do
  describe "#select_all" do
    it "returns scoped NCR records" do
      user = create(:user)
      proposal = create(:proposal, requester: user)
      create(:ncr_work_order, amount: 100, proposal: proposal)
      now = Time.current

      query = NcrDashboardQuery.new(user).select_all

      expect(query.to_a).to eq([{
        "year" => now.year.to_s,
        "month" => now.month.to_s,
        "count" => "1",
        "cost" => "100.0"
       }])
    end
  end
end
