describe ReportMailer do
  describe '.budget_status' do
    with_env_var('BUDGET_REPORT_RECIPIENT', 'budget@gsa.gov') do
      it "works with no data" do
        expect {
          ReportMailer.budget_status.deliver_later
        }.to_not raise_error
      end

      it "reports on work orders" do
        work_orders = 2.times.map do
          FactoryGirl.create(:ncr_work_order, :with_approvers)
        end

        ReportMailer.budget_status.deliver_now

        html = deliveries.last.body.encoded
        work_orders.each do |work_order|
          expect(html).to include(work_order.requester.email_address)
        end
      end
    end
  end
end
