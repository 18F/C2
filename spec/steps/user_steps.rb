module UserSteps

  step 'a valid user' do
    @user = User.find_or_create_by(email_address: 'test.user@some-dot-gov.gov')
    @user.update_attributes(first_name: "George", last_name: "Jetson")
  end

  step 'the user is :email' do |email|
    @user = User.find_by(email_address: email)
  end

  step 'the logged in user is :email' do |email|
    @user = User.find_by(email_address: email)

    user_info = {'email'=> email}
    page.set_rack_session('user' => user_info)
    @current_user = @user
  end

  step "I should see alert text :text" do |text|
    page.assert_selector('.alert', :count => 1)
    expect(page.find('.alert')).to have_content(text)
  end

  step "I should see :text" do |text|
    expect(page.find('body')).to have_content(text)
  end

  step "I should not see :text" do |text|
    expect(page.find('body')).to_not have_content(text)
  end

  step 'I should see a header :text' do |text|
    #TODO: Search through all header tags
    expect(page.find('h3')).to have_content(text)
  end

  step "I go to :page_name" do |page_name|
    visit "/#{page_name}"
  end

  step "I go to the cart view page" do
    visit "/carts/#{@cart.id}"
  end

  step "I login" do
    if @user
      login_as(@user)
    else
      login_with_oauth
    end
  end

  step 'show me the page' do
    save_and_open_page
  end

  step 'a cart :external_id' do |external_id|
    @cart = FactoryGirl.create(:cart_with_requester, external_id: external_id)
  end

  step 'a :cart_type cart :external_id' do |cart_type, external_id|
    @cart = FactoryGirl.create(:cart_with_requester, external_id: external_id, flow: cart_type)
  end

  step 'a cart and approvals' do
    @cart = FactoryGirl.create(:cart_with_approvals_and_items)
  end

  step 'a cart :external_id and approvals' do |external_id|
    @cart = FactoryGirl.create(:cart_with_approvals_and_items, external_id: external_id)
  end

  step 'I fill out :field with :text' do |field,text|
    Capybara.match = :first
    fill_in field, with: text
  end

  step 'I click :button_name button' do |button_name|
    Capybara.match = :first
    click_button(button_name)
  end

  step 'I click :link_name' do |link_name|
    Capybara.match = :first
    click_on(link_name)
  end

  step 'the page loads' do
    page.has_css?('.home-main-body')
  end

end
