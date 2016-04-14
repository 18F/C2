describe HistoryList do
  describe 'contents' do
    it "starts with proposal creation" do
      proposal = create(:proposal)

      history = HistoryList.new(proposal)
      expect(history.events.first.event).to eq("create")
    end

    describe "filtering" do
      it "excludes client data events" do
        work_order = create(:ncr_work_order)
        work_order.update(function_code: "blah!")
        history = HistoryList.new(work_order.proposal)

        expect(history.events.collect(&:item_type)).to_not include("Ncr::WorkOrder")
      end
    end
  end
end
