describe 'User creation when logging in with Oauth to view a protected page' do
  StructUser = Struct.new(:email_address, :first_name, :last_name)

  before do
    user = StructUser.new('george-test@example.com', 'Georgie', 'Jetsonian')
    setup_mock_auth(:myusa, user)
  end

  it 'creates a new user if the current user does not already exist' do
    expect(User.count).to eq 4 # seeds

    get '/auth/myusa/callback'

    expect(User.count).to eq 5 # 1 + 4 seeds
    expect(User.last.email_address).to eq('george-test@example.com')
  end

  it 'does not create a user if the current user already exists' do
    create(:user, email_address: 'george-test@example.com')
    expect(User.count).to eq 5 # 1 + 4 seeds

    get '/auth/myusa/callback'

    expect(User.count).to eq 5 # 1 + 4 seeds
  end

  it 'redirects a newly logged in user to the carts screen' do
    create(:user, email_address: 'george-test@example.com')
    expect(User.count).to eq 5 # 1 + 4 seeds

    get '/auth/myusa/callback'

    expect(response).to redirect_to('/proposals')
  end
end
