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

  def with_18f_env_variables(setup_vars=nil)
    ENV['GSA18F_APPROVER_EMAIL'] = 'test_approver@some-dot-gov.gov'
    ENV['GSA18F_PURCHASER_EMAIL'] = 'test_purchaser@some-dot-gov.gov'
    yield
    ENV['GSA18F_APPROVER_EMAIL'] = nil
    ENV['GSA18F_PURCHASER_EMAIL'] = nil
  end
end
