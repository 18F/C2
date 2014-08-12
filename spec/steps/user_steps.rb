module UserSteps
  step 'a valid user' do |something|
    raise 'hi'
  end

  step "I should see :text" do |text|
    raise 'hi'
  end

  # step "a confirmed user with a profile" do
  #   create_confirmed_user_with_profile
  # end

  # step "a logged in user" do
  #   create_confirmed_user
  #   login(@user)
  # end

  # step "I log in with user :user and password :password" do |user, password|
  #   fill_in 'user_email', :with => user
  #   fill_in 'user_password', :with => password
  #   click_button "Sign in"
  # end

  # step "I go to the homepage" do
  #   visit root_path
  # end

  # step "I go to the :page_name page" do |page_name|
  #   visit "/#{page_name}"
  # end

  # step "I should be on the homepage" do |pagename|
  #   expect(page.current_url).to eq("http://citizen.org/")
  # end

  # step "I should be on the :pagename page" do |pagename|
  #   expect(page.current_url).to eq("http://citizen.org/#{pagename}")
  # end

  # step "I should see the message :message" do |message|
  #   page.find('.alert').should have_content(message)
  # end
end
