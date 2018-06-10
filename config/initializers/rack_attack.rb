# config/initializers/rack_attack.rb (for rails apps)
Rack::Attack.throttle("requests by ip", limit: 100, period: 1) do |request|
  request.ip
end
