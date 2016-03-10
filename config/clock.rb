ENV["NEW_RELIC_DISPATCHER"] ||= "clockwork"

require "newrelic_rpm"
require "clockwork"
require_relative "boot"
require_relative "environment"

puts "Clockwork loaded."

module Clockwork
  if ENV["BUDGET_REPORT_RECIPIENT"] && ServerEnv.instance_index == 0
    every(1.day, "report_mailer.daily_budget_report", at: "03:30") do
      ClockTasks.send_daily_ncr_budget_report
    end

    every(1.week, "report_mailer.weekly_fiscal_year_report", at: "Monday 03:30") do
      ClockTasks.send_weekly_fiscal_year_ncr_budget_report
    end

    every(1.day, "scheduled_report.check", at: "04:00") do
      ClockTasks.scheduled_report_check
    end
  end
end
