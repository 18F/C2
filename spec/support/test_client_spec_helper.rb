module TestClientSpecHelper
  def test_models_exist?
    Test::ClientRequest.connection.table_exists?('test_client_requests')
  end
end

RSpec.configure do |config|
  include TestClientSpecHelper

  config.before :each, test_client_request: true do
    unless test_models_exist?
      Test.setup_models
    end
  end

  config.after :suite do
    if test_models_exist?
      Test.teardown_models
    end
  end
end
