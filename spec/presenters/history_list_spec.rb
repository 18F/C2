describe HistoryList do
  describe "#events" do
    it "returns a list of HistoryEvents" do
      proposal = create(:proposal, :with_serial_approvers)
      history_events = described_class.new(proposal).events

      expect(history_events).to all(be_instance_of(HistoryEvent))
    end

    describe "only lists relevant events" do
      it "omits client data creation" do
        work_order = create(:ncr_work_order)
        history_events = described_class.new(work_order.proposal).events

        expect(history_events.any? { |h| h.item_type == "Ncr::WorkOrder" }).to be_falsy
      end

      it "omits step creation" do
        proposal = create(:proposal, :with_serial_approvers)
        history_events = described_class.new(proposal).events

        expect(history_events.any? { |h| h.item_type == "Steps::Serial" }).to be_falsy
        expect(history_events.any? { |h| h.item_type == "Steps::Approval" }).to be_falsy
      end
    end
  end
end
