describe ReportMailer do
  describe '.budget_status' do
    it "works with no data" do
      expect {
        ReportMailer.budget_status.deliver_now
      }.to_not raise_error
    end
  end
end
