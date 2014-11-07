require 'spec_helper'

describe 'User creation when logging in with Oauth to view a protected page' do
  let(:mock_raw_info) { double }

  let(:extra_mock) {
    double(raw_info: mock_raw_info )
  }

  let(:credentials_mock) {
    double(token: '1a2b3c4d')
  }

  before do
    allow(OmniAuth.config.mock_auth[:myusa]).to receive(:extra).and_return(extra_mock)
    allow(OmniAuth.config.mock_auth[:myusa]).to receive(:credentials).and_return(credentials_mock)
  end

  it 'creates a new user if the current user does not already exist' do
    allow(mock_raw_info).to receive(:to_hash).and_return(
      'email'=>'a-brand-spankin-new-email@some-dot-gov.gov',
      'first_name'=>'Brand',
      'last_name'=>'Newsom'
    )

    expect(User.count).to eq 0
    get '/auth/myusa/callback'
    get '/approval_groups/new'

    expect(User.count).to eq 1
    expect(User.last.email_address).to eq 'a-brand-spankin-new-email@some-dot-gov.gov'
  end

  it 'does not create a user if the current user already exists' do
    FactoryGirl.create(:user, email_address: 'approver1@some-dot-gov.gov')
    allow(mock_raw_info).to receive(:to_hash).and_return(
      'email'=>'approver1@some-dot-gov.gov',
      'first_name'=>'Someone',
      'last_name' =>'Exists'
    )

    expect(User.count).to eq 1
    get '/auth/myusa/callback'
    get '/approval_groups/new'
    expect(User.count).to eq 1
  end
end
