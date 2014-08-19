module UserSteps
  step 'a valid user' do
    @user = FactoryGirl.create(:user)
  end

  step "I should see :text" do |text|
    page.find('.alert').should have_content(text)
  end

  step "I go to :page_name" do |page_name|
    visit "/#{page_name}"
  end

end
