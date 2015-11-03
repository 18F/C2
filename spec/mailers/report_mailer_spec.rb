describe ReportMailer do
  describe "#daily_budget_report" do
    with_env_var("BUDGET_REPORT_RECIPIENT", "budget@example.com") do
      it "works with no data" do
        expect {
          ReportMailer.daily_budget_report.deliver_later
        }.to_not raise_error
      end

      it "reports on work orders" do
        work_orders = 2.times.map do
          create(:ncr_work_order, :with_approvers)
        end

        ReportMailer.daily_budget_report.deliver_now

        html = deliveries.last.body.encoded
        work_orders.each do |work_order|
          expect(html).to include(work_order.requester.email_address)
        end

        attachments = deliveries.last.attachments
        expect(attachments.size).to eq 6
        attachments.each do |attachment|
          expect(attachment).to be_a_kind_of(Mail::Part)
          expect(attachment.content_type).to match('text/comma-separated-values')
        end
      end
    end
  end

  describe "#weekly_fiscal_year_report" do
    with_env_var("BUDGET_REPORT_RECIPIENT", "budget@example.com") do
      it "works with no data" do
        year = 2014

        Timecop.freeze(Time.local(year)) do

          expect {
            ReportMailer.weekly_fiscal_year_report(year).deliver_now
          }.to_not raise_error
        end
      end
    end
  end
end
