# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
C2::Application.config.secret_key_base = if Rails.env.development? or Rails.env.test?
  ('x' * 30)
else
  ENV.fetch("SECRET_TOKEN")
end
