# https://github.com/tomykaira/clockwork

ENV['NEW_RELIC_DISPATCHER'] ||= 'clockwork'

require 'newrelic_rpm'
require 'clockwork'
require_relative 'boot'
require_relative 'environment'

puts "Clockwork loaded."

module Clockwork
  if ENV['BUDGET_REPORT_RECIPIENT'] && ServerEnv.instance_index == 0
    every(1.day, 'report_mailer.budget_status', at: '03:30') do
      ClockTasks.send_ncr_budget_report
    end

    every(1.week, 'report_mailer.annual_ncr_report', at: 'Monday 03:30') do
      ClockTasks.send_annual_ncr_budget_report
    end
  end
end
