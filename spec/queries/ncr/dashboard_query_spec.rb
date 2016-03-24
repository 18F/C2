describe Ncr::DashboardQuery do
  describe "#select_all" do
    it "aggregates scoped NCR records" do
      user = create(:user)
      proposal = create(:proposal, requester: user)
      create(:ncr_work_order, amount: 100, proposal: proposal)
      now = Time.current.utc

      query = described_class.new(user).select_all

      expect(query.to_a).to eq([{
                                 "year" => now.year.to_s,
                                 "month" => now.month.to_s,
                                 "count" => "1",
                                 "cost" => "100.0"
                               }])
    end

    it "does not aggregate canceled NCR records" do
      user = create(:user)
      canceled_proposal = create(:proposal, requester: user)
      canceled_proposal.update(status: "canceled")
      create(:ncr_work_order, amount: 100, proposal: canceled_proposal)

      query = described_class.new(user).select_all

      expect(query.to_a).to eq([])
    end
  end
end
