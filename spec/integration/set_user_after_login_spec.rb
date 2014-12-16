describe 'User creation when logging in with Oauth to view a protected page' do
  before do
    setup_mock_auth
  end

  it 'creates a new user if the current user does not already exist' do
    expect(User.count).to eq 0
    get '/auth/myusa/callback'
    get '/approval_groups/new'

    expect(User.count).to eq 1
    expect(User.last.email_address).to eq('george.jetson@some-dot-gov.gov')
  end

  it 'does not create a user if the current user already exists' do
    FactoryGirl.create(:user, email_address: 'george.jetson@some-dot-gov.gov')

    expect(User.count).to eq 1
    get '/auth/myusa/callback'
    get '/approval_groups/new'
    expect(User.count).to eq 1
  end
end
