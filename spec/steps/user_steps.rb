module UserSteps
  def login_with_oauth(service = :myusa)
    mock_raw_info = double("raw_info_mock")

    mock_raw_info.stub(:to_hash).and_return(
      email: 'george.jetson@some-dot-gov.gov',
      first_name: "George",
      last_name: "Jetson"
    )

    extra_mock = double("mock_extra",
      raw_info: mock_raw_info
    )

    credentials_mock = double("myusa_creds",
      token: '1a2b3c4d'
    )

    OmniAuth.config.mock_auth[:myusa].stub(:extra).and_return(extra_mock)
    OmniAuth.config.mock_auth[:myusa].stub(:credentials).and_return(credentials_mock)

    mock_session = double("session_info",
      user: { email: 'hello@hello.com' }
    )

    user = @user ||= FactoryGirl.create(:user)
    ApplicationController.any_instance.stub(:current_user).and_return(user)

    visit "/auth/#{service}"
  end

  step 'a valid user' do
    @user = FactoryGirl.create(:user, first_name: "George", last_name: "Jetson")
  end

  step "I should see :text alert text" do |text|
    page.find('.alert').should have_content(text)
  end

  step "I should see :text success text" do |text|
    page.find('.success').should have_content(text)
  end

  step "I should see :text" do |text|
    page.find('body').should have_content(text)
  end

  step "I go to :page_name" do |page_name|
    visit "/#{page_name}"
  end

  step "I go to the cart view page" do
    visit "/carts/#{@cart.id}"
  end

  step "the user is logged in" do
    login_with_oauth
  end

  step "I login" do
    login_with_oauth
  end

  step 'show me the page' do
    save_and_open_page
  end

  step 'a cart with a cart item and approvals' do
    @cart = FactoryGirl.create(:cart_with_approvals_and_items)
  end

  step 'I fill out :field with :text' do |field,text|
    Capybara.match = :first
    fill_in field, with: text
  end

  step 'I click :button_name button' do |button_name|
    Capybara.match = :first
    click_button(button_name)
  end

end
