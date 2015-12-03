describe ClientSummarizer do
  describe "Ncr::WorkOrder" do
    it "builds summary" do
      wo = create(:ncr_work_order, amount: 123)
      summarizer = ClientSummarizer.new(client_namespace: "Ncr")
      summary = summarizer.run
      expect(summary.total).to eq(123)
      expect(summary.status(:pending)).to eq(1)
      expect(summary.subtotal(:pending)).to eq(123)
    end
  end

  describe "Gsa18f::Procurement" do
    it "builds summary" do
      procurement = create(:gsa18f_procurement, cost_per_unit: 18.50, quantity: 20)
      summarizer = ClientSummarizer.new(client_namespace: "Gsa18f")
      summary = summarizer.run
      expect(summary.total).to eq(370)
      expect(summary.status(:pending)).to eq(1)
      expect(summary.subtotal(:pending)).to eq(370)
    end
  end
end
