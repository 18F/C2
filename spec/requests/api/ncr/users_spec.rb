describe 'Users API' do
  # TODO share common functionality w/ other API specs

  def get_json(url)
    get(url)
    JSON.parse(response.body)
  end

  def time_to_s(time)
    time.iso8601(3)
  end

  before do
    # TODO clean this up
    ENV['API_ENABLED'] = 'true'
  end

  describe 'GET /api/v1/ncr/users.json' do
    it "responds with the list of users" do
      user = FactoryGirl.create(:user)
      json = get_json('/api/v1/ncr/users.json')
      expect(json).to eq([
        {
          'created_at' => time_to_s(user.created_at),
          'email_address' => user.email_address,
          'first_name' => user.first_name,
          'id' => user.id,
          'last_name' => user.last_name,
          'updated_at' => time_to_s(user.updated_at)
        }
      ])
    end

    it "responds with an empty list for no users" do
      json = get_json('/api/v1/ncr/users.json')
      expect(json).to eq([])
    end

    it "can be `limit`ed" do
      3.times do
        FactoryGirl.create(:user)
      end

      json = get_json('/api/v1/ncr/users.json?limit=2')
      expect(json.size).to eq(2)
    end

    it "can be `offset`" do
      users = 3.times.map do
        FactoryGirl.create(:user)
      end

      json = get_json('/api/v1/ncr/users.json?offset=1')

      ids = json.map {|user| user['id'] }
      expect(ids).to eq(users.map(&:id)[1..-1])
    end

    it "gives a 404 if API isn't enabled" do
      ENV.delete('API_ENABLED')

      expect {
        get '/api/v1/ncr/users.json'
      }.to raise_error(ActionController::RoutingError)
    end

    it "matches the format in the API documentation"

    describe "CORS" do
      let(:origin) { 'http://corsexample.com/' }
      let(:headers) {
        {
          'HTTP_ORIGIN' => origin,
          'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET'
        }
      }

      it "sets the Access-Control-Allow-Origin header to allow requests from anywhere" do
        get '/api/v1/ncr/users.json', {}, headers
        expect(response.headers['Access-Control-Allow-Origin']).to eq(origin)
      end

      it "allows general HTTP methods (GET/POST/PUT)" do
        get '/api/v1/ncr/users.json', {}, headers

        allowed_http_methods = response.header['Access-Control-Allow-Methods']
        %w{GET POST PUT}.each do |method|
          expect(allowed_http_methods).to include(method)
        end
      end

      it "supports OPTIONS requests" do
        options '/api/v1/ncr/users.json', {}, headers
        expect(response.status).to eq(200)
        expect(response.body).to eq('')
      end
    end
  end
end
