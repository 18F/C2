module IntegrationSpecHelper
  def setup_mock_auth(service_name = :myusa)
    OmniAuth.config.mock_auth[service_name] = OmniAuth::AuthHash.new(
      provider: service_name.to_s,
      raw_info: {
        'name' => "George Jetson"
      },
      uid: '12345',
      nickname: 'georgejetsonmyusa',
      extra: {
        'raw_info' => {
          'email' => 'george.jetson@some-dot-gov.gov',
          'first_name' => 'George',
          'last_name' => 'Jetson'
        }
      },
      credentials: {
        'token' => '1a2b3c4d'
      }
    )
  end

  def login_with_oauth(service_name = :myusa)
    setup_mock_auth(service_name)

    user = @user ||= FactoryGirl.create(:user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    visit "/auth/#{service_name}"
  end
end
