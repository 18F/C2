describe 'Users API' do
  # TODO share common functionality w/ other API specs

  describe 'GET /api/v1/users.json' do
    without_feature 'API_ENABLED' do
      it "gives a 403" do
        json = get_json('/api/v1/users.json')
        expect(response.status).to eq(403)
        expect(json['message']).to eq("Not authorized")
      end
    end

    with_feature 'API_ENABLED' do
      it "responds with the list of users" do
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

      it "includes the personal details when signed in" do
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

      it "default includes seed Users" do
        json = get_json('/api/v1/users.json')
        expect(json.size).to eq User.count
      end

      it "can be `limit`ed" do
        3.times do
          create(:user)
        end

        json = get_json('/api/v1/users.json?limit=2')
        expect(json.size).to eq(2)
      end

      it "can be `offset`" do
        users = 3.times.map do
          create(:user)
        end

        json = get_json('/api/v1/users.json?offset=1')

        ids = json.map {|user| user['id'] }
        expect(ids).to include(*users.map(&:id)[1..-1])
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
end
