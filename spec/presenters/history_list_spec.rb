describe HistoryList do
  describe '#events' do
    it "returns proposal creation as the first event" do
      proposal = create(:proposal)

      history = described_class.new(proposal)
      expect(history.events.first.event).to eq("create")
    end

    context "when the history contains client data events" do
      it "filters client data events out" do
        work_order = create(:ncr_work_order)
        work_order.update(function_code: "blah!")
        history = described_class.new(work_order.proposal)

        expect(history.events.collect(&:item_type)).to_not include("Ncr::WorkOrder")
      end
    end

    context "when the history contains step creation" do
      it "filters the step creation events out" do
        proposal = create(:proposal, :with_serial_approvers)
        history = described_class.new(proposal)

        expect(history.events.collect(&:item_type)).to_not include("Steps::Serial")
        expect(history.events.collect(&:item_type)).to_not include("Steps::Approval")
      end
    end
  end
end
