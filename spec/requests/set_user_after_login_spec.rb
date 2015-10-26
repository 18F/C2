describe 'User creation when logging in with Oauth to view a protected page' do
  StructUser = Struct.new(:email_address, :first_name, :last_name)

  before do
    user = StructUser.new('george-test@example.com', 'Georgie', 'Jetsonian')
    setup_mock_auth(:myusa, user)
  end

  it 'creates a new user if the current user does not already exist' do
    expect {
      get '/auth/myusa/callback'
    }.to change { User.count }.by(1)

    expect(User.last.email_address).to eq('george-test@example.com')
  end

  it 'does not create a user if the current user already exists' do
    create(:user, email_address: 'george-test@example.com')

    expect {
      get '/auth/myusa/callback'
    }.to_not change { User.count }
  end

  it 'redirects a newly logged in user to the carts screen' do
    create(:user, email_address: 'george-test@example.com')

    expect {
      get '/auth/myusa/callback'
    }.to_not change { User.count }

    expect(response).to redirect_to('/proposals')
  end
end
