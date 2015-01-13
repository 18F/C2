# verify that all keys in .env.example are present in the ENV, and warn about ones that are no longer used

def get_keys(path)
  contents = File.read(path)
  env_hash = Dotenv::Parser.call(contents)
  env_hash.keys
end

env_example_path = Rails.root.join('.env.example')
required_keys = get_keys(env_example_path)
required_keys.each do |key|
  ENV.fetch(key)
end

env_path = Rails.root.join('.env')
if File.exist?(env_path)
  env_keys = get_keys(env_path)
  extra_keys = env_keys - required_keys
  extra_keys.each do |key|
    Rails.logger.warn("Extra key in `.env`: #{key}")
  end
else
  Rails.logger.warn("No .env file.")
end


if ENV['HOST_URL']
  Rails.logger.warn("HOST_URL is deprecated – use DEFAULT_URL_HOST instead.")
end
