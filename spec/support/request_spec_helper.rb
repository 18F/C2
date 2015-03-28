module RequestSpecHelper
  # Add support for testing `options` requests in rspec.
  # https://gist.github.com/melcher/8854953
  def options(*args)
    reset! unless integration_session
    integration_session.__send__(:process, :options, *args).tap do
      copy_session_variables!
    end
  end
end
