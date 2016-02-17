describe 'Users API' do
  include EnvVarSpecHelper

  describe 'GET /api/v1/users.json' do
    it "gives a 403" do
      with_env_var("API_ENABLED", "false") do
        json = get_json('/api/v1/users.json')
        expect(response.status).to eq(403)
        expect(json['message']).to eq("Not authorized")
      end
    end

    it "responds with the list of users" do
      with_env_var("API_ENABLED", "true") do
        user = create(:user)
        json = get_json('/api/v1/users.json')

        expect(response.status).to eq(200)
        expect(json).to include(
          {
            'created_at' => time_to_json(user.created_at),
            'id' => user.id,
            'updated_at' => time_to_json(user.updated_at)
          }
        )
      end
    end

    it "includes the personal details when signed in" do
      with_env_var("API_ENABLED", "true") do
        user = create(:user)
        login_as(user)

        json = get_json('/api/v1/users.json')
        expect(json).to include(
          {
            'created_at' => time_to_json(user.created_at),
            'email_address' => user.email_address,
            'first_name' => user.first_name,
            'id' => user.id,
            'last_name' => user.last_name,
            'updated_at' => time_to_json(user.updated_at)
          }
        )
      end
    end

    it "default includes seed Users" do
      with_env_var("API_ENABLED", "true") do
        json = get_json('/api/v1/users.json')
        expect(json.size).to eq User.count
      end
    end

    it "can be `limit`ed" do
      with_env_var("API_ENABLED", "true") do
        create_list(:user, 3)
        json = get_json('/api/v1/users.json?limit=2')
        expect(json.size).to eq(2)
      end
    end

    it "can be `offset`" do
      with_env_var("API_ENABLED", "true") do
        users= create_list(:user, 3)
        json = get_json('/api/v1/users.json?offset=1')

        ids = json.map {|user| user['id'] }
        expect(ids).to include(*users.map(&:id)[1..-1])
      end
    end

    describe "CORS" do
      let(:origin) { 'http://corsexample.com/' }
      let(:headers) {
        {
          'HTTP_ORIGIN' => origin,
          'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET'
        }
      }

      it "sets the Access-Control-Allow-Origin header to allow requests from anywhere" do
        get '/api/v1/users.json', {}, headers
        expect(response.headers['Access-Control-Allow-Origin']).to eq(origin)
      end

      it "allows general HTTP methods (GET/POST/PUT)" do
        get '/api/v1/users.json', {}, headers

        allowed_http_methods = response.header['Access-Control-Allow-Methods']
        %w{GET POST PUT}.each do |method|
          expect(allowed_http_methods).to include(method)
        end
      end

      it "supports OPTIONS requests" do
        options '/api/v1/users.json', {}, headers
        expect(response.status).to eq(200)
        expect(response.body).to eq('')
      end
    end
  end
end
