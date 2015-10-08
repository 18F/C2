module FeatureSpecHelper
  # requires IntegrationSpecHelper

  def login_with_oauth
    user = FactoryGirl.create(:user)
    login_as(user)
  end

  def login_as(user)
    setup_mock_auth(:myusa, user)
    visit '/auth/myusa'
  end

  def focus_field(field_id)
    execute_script "document.getElementById('#{field_id}').scrollIntoView()"
    execute_script "$('##{field_id}').focus()"
  end
end
