describe ReportMailer, :email do
  include EnvVarSpecHelper

  describe "#daily_budget_report" do
    it "works with no data" do
      with_env_var("BUDGET_REPORT_RECIPIENT", "budget@example.com") do
        expect {
          ReportMailer.daily_budget_report.deliver_later
        }.to_not raise_error
      end
    end

    it "reports on work orders" do
      with_env_var("BUDGET_REPORT_RECIPIENT", "budget@example.com") do
        deliveries.clear
        work_orders = create_list(:ncr_work_order, 2, :with_approvers)
        ReportMailer.daily_budget_report.deliver_now

        html = deliveries.last.body.encoded
        work_orders.each do |work_order|
          expect(html).to include(work_order.requester.email_address)
        end

        attachments = deliveries.last.attachments
        expect(attachments.size).to eq 5
        attachments.each do |attachment|
          expect(attachment).to be_a_kind_of(Mail::Part)
          expect(attachment.content_type).to match('text/csv')
        end
      end
    end
  end

  describe "#weekly_fiscal_year_report" do
    it "works with no data" do
      with_env_var("BUDGET_REPORT_RECIPIENT", "budget@example.com") do
        year = 2014

        Timecop.freeze(Time.local(year)) do

          expect {
            ReportMailer.weekly_fiscal_year_report(year).deliver_now
          }.to_not raise_error
        end
      end
    end
  end

  describe "#scheduled_report" do
    it "mails report on schedule", :elasticsearch do
      deliveries.clear
      owner = create(:user)
      report = create(:report, query: { text: "something" }.to_json, user: owner)
      scheduled_report = create(:scheduled_report, frequency: "daily", user: owner, report: report)

      proposals = 3.times.map do |i|
        tcr = create(:test_client_request, project_title: "something #{i}")
        tcr.proposal.update(requester: owner)
        tcr.proposal.reindex
        tcr.proposal
      end
      Proposal.__elasticsearch__.refresh_index!

      email = ReportMailer.scheduled_report(scheduled_report.name, scheduled_report.report, scheduled_report.user)

      expect(email.to).to eq([owner.email_address])
      expect(email.attachments.size).to eq(1)
      expect(email.attachments.first).to be_a_kind_of(Mail::Part)

      csv = email.attachments.first.decode_body
      expect(csv).to include("something 1")
      expect(csv).to include("something 2")
      expect(csv.split(/\n/).size).to eq(4)
    end
  end
end
