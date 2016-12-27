CG_KEY       = OauthCredentials.cg_app_id
CG_SECRET    = OauthCredentials.cg_app_secret
CG_URL       = ENV["CG_URL"] || "https://login.fr.cloud.gov"
CG_TOKEN_URL = ENV["CG_TOKEN_URL"] || "https://uaa.fr.cloud.gov"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cg,
           CG_KEY,
           CG_SECRET,
           client_options: {
             site: CG_URL,
             token_url: "#{CG_TOKEN_URL}/oauth/token"
           }
end
