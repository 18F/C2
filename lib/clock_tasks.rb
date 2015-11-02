# This class mostly exists to be instrumented by New Relic. Make sure any new methods set up an `add_transaction_tracer`.
# https://docs.newrelic.com/docs/agents/ruby-agent/background-jobs/monitoring-ruby-background-processes-daemons#custom_background_jobs
class ClockTasks
  def self.send_daily_ncr_budget_report
    puts "SENDING BUDGET REPORT..."
    ReportMailer.daily_budget_report.deliver_later
    puts "...DONE"
  end

  def self.send_weekly_fiscal_year_ncr_budget_report
    puts "SENDING WEEKLY FISCAL YEAR BUDGET REPORT..."
    now = Time.zone.now
    fiscal_year = Ncr::WorkOrder.which_fiscal_year(now.year, now.month)
    ReportMailer.weekly_fiscal_year_report(fiscal_year).deliver_later
    puts "...DONE"
  end

  class << self
     include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
     add_transaction_tracer :send_ncr_budget_report, category: :task
  end
end
