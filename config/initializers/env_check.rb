# verify that all keys in .env.example are present in the ENV, and warn about ones that are no longer used

def get_keys(env_file)
  path = Rails.root.join(env_file)
  contents = if File.exists?(path)
      File.read(path)
    else
      ''
    end
  env_hash = Dotenv::Parser.call(contents)
  env_hash.keys
end

required_keys = get_keys('.env.example')
required_keys.each do |key|
  ENV.fetch(key)
end

env_keys = get_keys('.env')
extra_keys = env_keys - required_keys
extra_keys.each do |key|
  $stderr.puts "NOTE: extra key in `.env`: #{key}"
end


if ENV['HOST_URL']
  Rails.logger.warn("HOST_URL is deprecated – use DEFAULT_URL_HOST instead.")
end
