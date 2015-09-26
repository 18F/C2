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

  # adapted from http://stackoverflow.com/a/25047358
  def fill_in_selectized(key, *values)
    values.flatten.each do |value|
      page.execute_script("$('##{key}').selectize()[0].selectize.setValue('#{value}')")
    end
  end
end
