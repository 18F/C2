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

  def login_with_oauth
    user = FactoryGirl.create(:user)
    login_as(user)
  end

  def login_as(user)
    setup_mock_auth(:myusa, user)
    visit '/auth/myusa'
  end
end
