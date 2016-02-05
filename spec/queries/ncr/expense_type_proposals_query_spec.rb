describe Ncr::ExpenseTypeProposalsQuery do
  describe ".find" do
    it "returns approved proposals with an expense type passed in created since the date passed in" do
      old_ba_60_proposal = create(:proposal, status: "approved", created_at: 1.month.ago)
      _old_ba_60_work_order = create(:ba60_ncr_work_order, proposal: old_ba_60_proposal)
      new_ba_60_proposal = create(:proposal, status: "approved", created_at: 1.day.ago)
      _new_ba_60_work_order = create(:ba60_ncr_work_order, proposal: new_ba_60_proposal)
      new_ba_80_proposal = create(:proposal, status: "approved", created_at: 1.day.ago)
      _new_ba_80_work_order = create(:ba80_ncr_work_order, proposal: new_ba_80_proposal)

      proposals = Ncr::ExpenseTypeProposalsQuery.new(expense_type: "BA60", time_delimiter: 1.week.ago).find

      expect(proposals).to match_array [new_ba_60_proposal]
    end
  end
end
