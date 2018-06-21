# Throttle high volumes of requests by IP address
# This is a fairly high threshhold to see if it causes any issues. We can adjust in the future
Rack::Attack.throttle('req/ip', limit: 100, period: 5.seconds) do |req|
  req.ip unless req.path.starts_with?('/assets')
end
