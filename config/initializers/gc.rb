# https://docs.newrelic.com/docs/agents/ruby-agent/features/garbage-collection
if Rails.env.production?
  GC::Profiler.enable
end
