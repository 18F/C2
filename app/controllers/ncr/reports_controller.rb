module Ncr
  class ReportsController < ApplicationController
    # TODO limit to local requests

    def send_report
      ReportMailer.budget_status.deliver_now
      render text: 'done'
    end
  end
end
