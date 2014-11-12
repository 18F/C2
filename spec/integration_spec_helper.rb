module IntegrationSpecHelper
  def login_with_oauth(service = :myusa)
    mock_raw_info = double("raw_info_mock")

    allow(mock_raw_info).to receive(:to_hash).and_return(
      email: 'george.jetson@some-dot-gov.gov',
      first_name: "George",
      last_name: "Jetson"
    )

    extra_mock = double("mock_extra",
      raw_info: mock_raw_info
    )

    credentials_mock = double("myusa_creds",
      token: '1a2b3c4d'
    )

    OmniAuth.config.mock_auth[:myusa].extra = extra_mock
    OmniAuth.config.mock_auth[:myusa].credentials = credentials_mock

    mock_session = double("session_info",
      user: { email: 'hello@hello.com' }
    )

    user = @user ||= FactoryGirl.create(:user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    visit "/auth/#{service}"
  end
end
