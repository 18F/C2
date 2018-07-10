# Be sure to restart your server when you modify this file.

C2::Application.config.session_store(
  :cookie_store,
  key: "_c2_session",
  expire_after: 60.minutes,
  secure: Rails.env.production?
  # domain: 'localhost'
)
