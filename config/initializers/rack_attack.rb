# Throttle high volumes of requests by IP address
# This is a fairly high threshhold to see if it causes any issues. We can adjust in the future
requests_limit = ENV["REQUESTS_LIMIT"] ? ENV["REQUESTS_LIMIT"] : 200
requests_limit_period = ENV["REQUESTS_LIMIT_PERIOD"] ? ENV["REQUESTS_LIMIT_PERIOD"] : 60

Rack::Attack.throttle("requests/ip", limit: requests_limit.to_i, period: requests_limit_period.to_i) do |req|
  req.ip unless req.path.starts_with?("/assets")
end
