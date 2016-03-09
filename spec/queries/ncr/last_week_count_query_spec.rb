describe Ncr::LastWeekCountQuery do
  describe ".find" do
    it "returns the count of NCR proposals created in the past week" do
      _old_work_order = create(:ncr_work_order, created_at: 1.month.ago)
      _new_work_order = create(:ncr_work_order, created_at: 1.day.ago)

      expect(Ncr::LastWeekCountQuery.new.find).to eq 1
    end
  end
end
