module RequestSpecHelper
  def get_json(url)
    get(url)
    puts response.pretty_inspect
    JSON.parse(response.body)
  end

  # requires IntegrationSpecHelper
  def login_as(user)
    setup_mock_auth(:myusa, user)
    get '/auth/myusa/callback'
  end

  def time_to_json(time)
    time.utc.iso8601(3)
  end

  # Add support for testing `options` requests in rspec.
  # https://gist.github.com/melcher/8854953
  def options(*args)
    reset! unless integration_session
    integration_session.__send__(:process, :options, *args).tap do
      copy_session_variables!
    end
  end

  def mock_api_doorkeeper_pass
    user = create(:user, client_slug: "test")
    dummy_app = double owner: user
    dummy_token = double :acceptable? => true, application: dummy_app
    allow_any_instance_of(Api::BaseController).to receive(:doorkeeper_token) {dummy_token}
    user
  end
end
