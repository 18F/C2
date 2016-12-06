module RequestSpecHelper
  include ApiSpecHelper

  def get_json(url)
    get(url)
    JSON.parse(response.body)
  end

  # requires IntegrationSpecHelper
  def login_as(user)
    setup_mock_auth(:cg, user)
    get '/auth/cg/callback'
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
end
