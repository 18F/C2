module IntegrationSpecHelper
  def setup_mock_auth(service_name=:myusa, user=FactoryGirl.create(:user))
    OmniAuth.config.mock_auth[service_name] = OmniAuth::AuthHash.new(
      provider: service_name.to_s,
      raw_info: {
        'name' => "George Jetson"
      },
      uid: '12345',
      nickname: 'georgejetsonmyusa',
      extra: {
        'raw_info' => {
          'email' => user.email_address,
          'first_name' => user.first_name,
          'last_name' => user.last_name
        }
      },
      credentials: {
        'token' => '1a2b3c4d'
      }
    )
  end

  def login_with_oauth(service_name = :myusa)
    user = @user ||= FactoryGirl.create(:user)
    setup_mock_auth(service_name, user)

    visit "/auth/#{service_name}"
  end
end
