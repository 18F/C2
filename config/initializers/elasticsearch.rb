require "elasticsearch/model"
require "json"

# defaults
es_client_args = {
  transport_options: {
    request: {
      timeout: 1 * 60,
      open_timeout: 1 * 60
    }
  },
  retry_on_failure: 5
}

def es_config_from_vcap(vcap)
  vcap_config = JSON.parse(vcap)
  es_config_keys = vcap_config.keys.select { |i| i.match(/elasticsearch/) }
  if es_config_keys.length > 1
    Rails.logger.warn "More than one CF service key containing 'elasticsearch'. Using the first."
  end
  es_config_from_service(vcap_config[es_config_keys.first][0])
end

def es_config_from_service(es_service)
  if es_service["credentials"]["uri"]
    es_client_args[:url] = es_service["credentials"]["uri"]
  else
    es_client_args[:hosts] = [{
      host: es_service["credentials"]["hostname"],
      port: es_service["credentials"]["port"],
      user: es_service["credentials"]["username"],
      password: es_service["credentials"]["password"]
    }]
  end
end

# we use "production" env for all things at cloud.gov
if Rails.env.production?
  vcap = ENV["VCAP_SERVICES"]
  es_config_from_vcap(vcap)
elsif Rails.env.test?
  es_client_args[:url] = "http://localhost:#{(ENV['TEST_CLUSTER_PORT'] || 9250)}"
else
  es_client_args[:url] = ENV["ES_URL"] || "http://localhost:9200"
end

# optional verbose logging based on env var, regardless of environment.
if ENV["ES_DEBUG"]
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
