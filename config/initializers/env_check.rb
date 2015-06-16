# verify that all keys in .env.example are present in the ENV, and warn about ones that are no longer used

def get_keys(env_file)
  path = Rails.root.join(env_file)
  contents = File.read(path)
  env_hash = Dotenv::Parser.call(contents)
  env_hash.keys
end

required_keys = get_keys('.env.example')
required_keys.each do |key|
  ENV.fetch(key)
end


if ENV['NCR_BA61_TIER2_BUDGET_MAILBOX']
  Rails.logger.warn("NCR_BA61_TIER2_BUDGET_MAILBOX is deprecated. Please use NCR_BA61_BUDGET_MAILBOX instead.")
end


if ENV['HOST_URL']
  Rails.logger.warn("HOST_URL is deprecated – use DEFAULT_URL_HOST instead.")
end

default_url_host = ENV['DEFAULT_URL_HOST']
if default_url_host.nil? && Rails.env.production?
  raise "Please set DEFAULT_URL_HOST"
end

DEFAULT_URL_HOST = default_url_host || ENV['HOST_URL'] || 'localhost'
