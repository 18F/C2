module FeatureSpecHelper
  def login_with_oauth
    user = create(:user)
    login_as(user)
  end

  def login_as(user)
    setup_mock_auth(:myusa, user)
    visit '/auth/myusa'
  end
end
