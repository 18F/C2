describe Ncr::UnapprovedCountQuery do
  describe ".find" do
    it "returns the number of pending proposals for NCR" do
      pending_proposal = create(:proposal, status: "pending")
      approved_proposal = create(:proposal, status: "approved")
      create(:ncr_work_order, proposal: pending_proposal)
      create(:ncr_work_order, proposal: approved_proposal)

      expect(Ncr::UnapprovedCountQuery.new.find).to eq 1
    end
  end
end
