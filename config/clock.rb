# https://github.com/tomykaira/clockwork

ENV['NEW_RELIC_DISPATCHER'] ||= 'clockwork'

require 'newrelic_rpm'
require 'clockwork'
require_relative 'boot'
require_relative 'environment'

puts "Clockwork started."
puts NewRelic::Agent.config[:dispatcher]

module Clockwork
  # TODO feature-flag this
  # TODO do at a certain time
  # TODO only do on first Cloud Foundry instance_index
  every(30.seconds, 'frequent.job', thread: true) do
    puts "SENDING TEST REPORT..."
    ReportMailer.budget_status.deliver_now
    puts "...DONE"
  end
end
