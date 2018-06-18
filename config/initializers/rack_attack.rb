# Throttle high volumes of requests by IP address
Rack::Attack.throttle('req/ip', limit: 20, period: 20.seconds) do |req|
  req.ip unless req.path.starts_with?('/assets')
end