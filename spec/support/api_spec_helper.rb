module ApiSpecHelper
  def mock_api_doorkeeper_pass
    user = create(:user, client_slug: "test")
    dummy_app = double owner: user
    dummy_token = double :acceptable? => true, application: dummy_app
    allow_any_instance_of(Api::V2::BaseController).to receive(:doorkeeper_token) {dummy_token}
    user
  end
end
