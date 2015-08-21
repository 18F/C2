describe ReportMailer do
  describe '.budget_status' do
    with_env_var('BUDGET_REPORT_RECIPIENT', 'budget@gsa.gov') do
      it "works with no data" do
        expect {
          ReportMailer.budget_status.deliver_later
        }.to_not raise_error
      end
    end
  end
end
