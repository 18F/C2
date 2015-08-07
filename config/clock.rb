# https://github.com/tomykaira/clockwork

ENV['NEW_RELIC_DISPATCHER'] ||= 'clockwork'

require 'newrelic_rpm'
require 'clockwork'
require_relative 'boot'
require_relative 'environment'

puts "Clockwork loaded."

module Clockwork
  if ENV['BUDGET_REPORT_RECIPIENT'] && ServerEnv.instance_index == 0
    every(1.day, 'report_mailer.budget_status', at: '03:30', thread: true) do
      puts "SENDING TEST REPORT..."
      ReportMailer.budget_status.deliver_now
      puts "...DONE"
    end
  end
end
