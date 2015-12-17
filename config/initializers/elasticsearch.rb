require "elasticsearch/model"
require "json"

# defaults
es_client_args = {
  transport_options: {
    request: {
      timeout: 1800,
      open_timeout: 1800,
    }
  },
  retry_on_failure: 5,
}

# we use "production" env for all things at cloud.gov
if Rails.env.production?
  vcap = ENV["VCAP_SERVICES"]
  es_config = JSON.parse(vcap)["elasticsearch-new"]
  es_client_args[:url] = es_config["url"]
elsif Rails.env.test?
  es_client_args[:url] = "http://localhost:#{(ENV['TEST_CLUSTER_PORT'] || 9250)}"
else
  es_client_args[:url] = ENV["ES_URL"] || "http://localhost:9200"
end

# optional verbose logging based on env var, regardless of environment.
if ENV["ES_DEBUG"].to_i > 0
  logger = Logger.new(STDOUT)
  logger.level = Logger::DEBUG
  tracer = Logger.new(STDERR)
  tracer.formatter = ->(_s, _d, _p, m) { "#{m.gsub(/^.*$/) { |n| '   ' + n }}\n" }
  es_client_args[:log] = true
  es_client_args[:logger] = logger
  es_client_args[:tracer] = tracer
  logger.debug "[#{Time.now.utc.iso8601}] Elasticsearch logging set to DEBUG mode"
end

Elasticsearch::Model.client = Elasticsearch::Client.new(es_client_args)

if ENV["ES_DEBUG"]
  es_client_args[:logger].debug "[#{Time.now.utc.iso8601}] Using Elasticsearch server #{es_client_args[:url]}"
end
