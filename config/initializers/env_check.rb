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


if ENV['HOST_URL']
  Rails.logger.warn("HOST_URL is deprecated – use DEFAULT_URL_HOST instead.")
end
