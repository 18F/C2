describe "API v2" do
  describe "CORS" do
    it "sets the Access-Control-Allow-Origin header to allow requests from anywhere" do
      mock_api_doorkeeper_pass

      get "/api/v2/proposals", {}, cors_headers

      expect(response.headers['Access-Control-Allow-Origin']).to eq(cors_origin)
    end 

    it "allows general HTTP methods (GET/POST/PUT)" do
      mock_api_doorkeeper_pass

      get "/api/v2/proposals", {}, cors_headers

      allowed_http_methods = response.header['Access-Control-Allow-Methods']
      %w{GET POST PUT}.each do |method|
        expect(allowed_http_methods).to include(method)
      end 
    end 

    it "supports OPTIONS requests" do
      mock_api_doorkeeper_pass

      options "/api/v2/proposals", {}, cors_headers

      expect(response.status).to eq(200)
      expect(response.body).to eq('')
    end 
  end

  describe "authenticate" do
    it "returns valid oauth token" do
      user = create(:user, client_slug: "test")
      oauth_application = oauth_application(user)
      oauth_token = oauth_token(oauth_application)

      expect(oauth_token).to eq(oauth_application.access_tokens.first.token)
    end
  end

  describe "GET proposal" do
    it "returns 403 if requesting unauthorized proposal" do
      user = create(:user, client_slug: "test")
      oauth_application = oauth_application(user)
      oauth_token = oauth_token(oauth_application)
      proposal = create(:proposal)

      get "/api/v2/proposals/#{proposal.id}", nil, { Authorization: oauth_authz_header(oauth_token) }

      expect(response.status).to eq(403)
    end
  end

  def cors_headers
    {
      "HTTP_ORIGIN" => cors_origin,
      "HTTP_ACCESS_CONTROL_REQUEST_METHOD" => "GET"
    }
  end

  def cors_origin
    "http://corsexample.com/"
  end

  def response_json
    JSON.parse(response.body)
  end

  def oauth_authz_header(oauth_token)
    "Bearer #{oauth_token}"
  end

  def oauth_authn_header(oauth_application)
    "Basic #{Base64.urlsafe_encode64("#{oauth_application.uid}:#{oauth_application.secret}")}"
  end

  def oauth_token(oauth_application)
    auth_header = oauth_authn_header(oauth_application)
    post "/oauth/token", { grant_type: "client_credentials" }, { Authorization: auth_header }
    JSON.parse(response.body)["access_token"]
  end
 
  def oauth_application(owner)
    Doorkeeper::Application.create!(name: "test oauth app", redirect_uri: default_redirect_uri, owner: owner)
  end

  def default_redirect_uri
    "urn:ietf:wg:oauth:2.0:oob"
  end
end
