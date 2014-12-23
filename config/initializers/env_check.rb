# verify that all keys in .env.example are present in the ENV

filename = Rails.root.join('.env.example')
contents = File.read(filename)
example_env = Dotenv::Parser.call(contents)
required_keys = example_env.keys

required_keys.each do |key|
  ENV.fetch(key)
end
