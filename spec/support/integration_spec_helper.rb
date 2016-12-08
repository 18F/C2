module IntegrationSpecHelper
  def setup_mock_auth(service_name=:cg, user=create(:user))
    OmniAuth.config.mock_auth[service_name] = OmniAuth::AuthHash.new(
      provider: service_name.to_s,
      raw_info: {
        'name' => "George Jetson"
      },
      uid: '12345',
      nickname: 'georgejetsoncg',
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
end
