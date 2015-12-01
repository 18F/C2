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
end
