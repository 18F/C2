describe HistoryList do
  before(:each) { PaperTrail.enabled = true }
  after(:each) { PaperTrail.enabled = false }

  describe '#events' do
    it "returns proposal creation as the first event" do
      proposal = create(:proposal)

      history = described_class.new(proposal)
      expect(history.events.first.event).to eq("create")
    end

    context "when the history contains client data creation events" do
      it "filters client data creation events out" do
        work_order = create(:ncr_work_order)
        history = described_class.new(work_order.proposal)

        expect(history.events.collect(&:item_type)).not_to include("Ncr::WorkOrder")
      end
    end

    context "when the history contains client data update events" do
      it "does not filter client data update events out" do
        work_order = create(:ncr_work_order)
        work_order.update(function_code: "PG999")
        work_order.save!
        history = described_class.new(work_order.proposal)

        expect(history.events.collect(&:item_type)).to include("Ncr::WorkOrder")
      end
    end

    context "when the history contains step creation" do
      it "filters the step creation events out" do
        proposal = create(:proposal, :with_serial_approvers)
        history = described_class.new(proposal)

        expect(history.events.collect(&:item_type)).not_to include("Steps::Serial")
        expect(history.events.collect(&:item_type)).not_to include("Steps::Approval")
      end
    end
  end
end
