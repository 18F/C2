describe Ncr::UnapprovedCountQuery do
  describe "#find" do
    it "returns the number of pending proposals for NCR" do
      orig_count = Ncr::UnapprovedCountQuery.new.find

      pending_proposal = create(:proposal, status: "pending")
      completed_proposal = create(:proposal, status: "completed")
      create(:ncr_work_order, proposal: pending_proposal)
      create(:ncr_work_order, proposal: completed_proposal)

      expect(Ncr::UnapprovedCountQuery.new.find).to eq(orig_count + 1)
    end
  end
end
