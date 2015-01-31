describe 'User creation when logging in with Oauth to view a protected page' do
  before do
    StructUser = Struct.new(:email_address, :first_name, :last_name)
    user = StructUser.new('george-test@some-dot-gov.gov', 'Georgie', 'Jetsonian')
    setup_mock_auth(:myusa, user)
  end

  it 'creates a new user if the current user does not already exist' do
    expect(User.count).to eq 0
    get '/auth/myusa/callback'
    get '/approval_groups/new'

    expect(User.count).to eq 1
    expect(User.last.email_address).to eq('george-test@some-dot-gov.gov')
  end

  it 'does not create a user if the current user already exists' do
    FactoryGirl.create(:user, email_address: 'george-test@some-dot-gov.gov')

    expect(User.count).to eq 1
    get '/auth/myusa/callback'
    get '/approval_groups/new'
    expect(User.count).to eq 1
  end

  it 'redirects a newly logged in user to the carts screen' do
    FactoryGirl.create(:user, email_address: 'george-test@some-dot-gov.gov')

    expect(User.count).to eq 1
    get '/auth/myusa/callback'
    expect(response).to redirect_to('/carts')
  end
end
