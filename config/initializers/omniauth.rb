MYUSA_KEY    = ENV.fetch "MYUSA_KEY"
MYUSA_SECRET = ENV.fetch "MYUSA_SECRET"
MYUSA_URL    = ENV["MYUSA_URL"] || "https://alpha.my.usa.gov"

CG_KEY       = ENV.fetch "CG_APP_ID"
CG_SECRET    = ENV.fetch "CG_APP_SECRET"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :myusa, MYUSA_KEY, MYUSA_SECRET, scope: "profile.email",
                                            client_options: {
                                              site: MYUSA_URL,
                                              token_url: "/oauth/authorize"
                                            }

  provider :cg, CG_KEY, CG_SECRET
end
