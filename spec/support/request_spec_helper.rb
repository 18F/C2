module RequestSpecHelper
  # requires IntegrationSpecHelper

  def login_as(user)
    setup_mock_auth(:myusa, user)
    get '/auth/myusa/callback'
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
