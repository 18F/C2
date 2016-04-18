describe HistoryList do
  describe '#events' do
    it "returns proposal creation as the first event" do
      proposal = create(:proposal)

      history = HistoryList.new(proposal)
      expect(history.events.first.event).to eq("create")
    end

    context "when the history contains client data events" do
      it "filters client data events out" do
        work_order = create(:ncr_work_order)
        work_order.update(function_code: "blah!")
        history = HistoryList.new(work_order.proposal)

        expect(history.events.collect(&:item_type)).to_not include("Ncr::WorkOrder")
      end
    end
  end
end
