# This class mostly exists to be instrumented by New Relic. Make sure any new methods set up an `add_transaction_tracer`.
# https://docs.newrelic.com/docs/agents/ruby-agent/background-jobs/monitoring-ruby-background-processes-daemons#custom_background_jobs
class ClockTasks
  def self.send_ncr_budget_report
    puts "SENDING BUDGET REPORT..."
    ReportMailer.budget_status.deliver_later
    puts "...DONE"
  end

  class << self
     include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
     add_transaction_tracer :send_ncr_budget_report, category: :task
  end
end
