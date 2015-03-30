describe "CORS requests for cart creation" do
  let(:params) { read_fixture('cart_without_approval_group') }
  let(:json_params) { JSON.parse(params) }

  it "sets the Access-Control-Allow-Origin header to allow CORS from anywhere" do
    origin = 'http://corsexample.com/'
    post '/send_cart', json_params, {
      'HTTP_ORIGIN' => origin,
      'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'POST'
    }
    expect(response.headers['Access-Control-Allow-Origin']).to eq(origin)
  end

  it "allows general HTTP methods (GET/POST/PUT) through CORS" do
    post '/send_cart', json_params, {
      'HTTP_ORIGIN' => 'http://corsexample.com/',
      'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'POST'
    }

    allowed_http_methods = response.header['Access-Control-Allow-Methods']
    %w{GET POST PUT}.each do |method|
      expect(allowed_http_methods).to include(method)
    end
  end

  it "skips the actual action for OPTIONS requests" do
    expect_any_instance_of(CommunicartsController).to_not receive(:send_cart)

    options '/send_cart', {}, {
      'HTTP_ORIGIN' => 'http://corsexample.com/',
      'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'POST'
    }

    expect(response.status).to eq(200)
    expect(response.body).to eq('')
  end
end
