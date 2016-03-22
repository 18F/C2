describe Ncr::DashboardQuery do
  describe "#select_all" do
    it "returns scoped NCR records" do
      user = create(:user)
      proposal = create(:proposal, requester: user)
      # canceled proposals should be excluded from the totals
      proposal2 = create(:proposal, requester: user)
      proposal2.update(status: "canceled")
      create(:ncr_work_order, amount: 100, proposal: proposal)
      create(:ncr_work_order, amount: 100, proposal: proposal2)
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
